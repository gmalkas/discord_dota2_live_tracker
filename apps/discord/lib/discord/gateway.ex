defmodule Discord.Gateway do
  use GenServer
  require Logger

  defstruct [:timeout, :token, :socket]

  @version 5
  @encoding :json
  @query_params %{v: @version, encoding: @encoding}
  @default_timeout :timer.seconds(60) # 1 minute may be too long?

  alias Discord.API
  alias Discord.Gateway.{Protocol}
  alias Protocol.{Heartbeat, Hello, Identify}
  alias __MODULE__

  def start_link(token) do
    GenServer.start_link(__MODULE__, token, [])
  end

  def init(token) do
    setup()
    {:ok, %Gateway{timeout: @default_timeout, token: token}}
  end

  defp setup do
    GenServer.cast(self(), :setup)
  end

  defp move_to(state) do
    GenServer.cast(self(), state)
  end

  def handle_cast(:setup, %Gateway{token: token} = gateway) do
    socket = token
    |> fetch_gateway_uri
    |> connect(token)

    move_to(:wait_for_hello)

    {:noreply, %Gateway{gateway | socket: socket}}
  end

  def handle_cast(:wait_for_hello, %Gateway{} = state) do
    %Hello{heartbeat_interval: interval_in_ms} = next_message(state.socket, state.timeout)
    start_hearbeat(state.socket, interval_in_ms)
    move_to(:identify)

    {:noreply, %Gateway{state | timeout: timeout_from_hearbeat_interval(interval_in_ms)}}
  end

  def handle_cast(:identify, %Gateway{socket: socket} = state) do
    send_message(socket, Identify.with_token(state.token))
    move_to(:receive_loop)

    {:noreply, state}
  end

  def handle_cast(:receive_loop, %Gateway{} = state) do
    next_message(state.socket, state.timeout)

    move_to(:receive_loop)

    {:noreply, state}
  end

  defp fetch_gateway_uri(token) do
    {:ok, websocket_url} = API.Gateway.url(token)
    URI.parse(websocket_url)
  end

  defp connect(uri, token) do
    {:ok, socket} = Socket.Web.connect(
      uri.host,
      headers: API.headers(token),
      path: "/?#{URI.encode_query(@query_params)}",
      secure: true
    )
    socket
  end

  defp next_message(socket, timeout) do
    {:text, data} = Socket.Web.recv!(socket, timeout: timeout)
    {:ok, message} = Protocol.decode(data)
    Logger.info(inspect message)
    message
  end

  defp send_message(socket, message) do
    Logger.info(Protocol.encode(message))
    Socket.Web.send!(socket, {:text, Protocol.encode(message)})
  end

  defp timeout_from_hearbeat_interval(interval_in_ms) do
    interval_in_ms * 2
  end

  defp start_hearbeat(socket, interval_in_ms) do
    Logger.info "Starting heartbeats every #{interval_in_ms}ms"
    {:ok, _} = Task.start_link(fn -> beat(socket, interval_in_ms) end)
  end

  defp beat(socket, interval_in_ms) do
    send_message(socket, %Heartbeat{})
    :timer.sleep(interval_in_ms)

    beat(socket, interval_in_ms)
  end
end
