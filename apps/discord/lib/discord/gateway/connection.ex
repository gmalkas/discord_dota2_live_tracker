defmodule Discord.Gateway.Connection do
  use GenServer
  require Logger

  defstruct [:timeout, :token, :url, :socket]

  @version 5
  @encoding :json
  @query_params %{v: @version, encoding: @encoding}
  @default_timeout :timer.seconds(60) # 1 minute may be too long?

  alias Discord.API
  alias Discord.Gateway.{Broker, Protocol, Session}
  alias Protocol.{Heartbeat, HeartbeatAck, Hello, Identify, InvalidSession, Reconnect, Resume}
  alias __MODULE__

  def start_link(token) do
    GenServer.start_link(__MODULE__, token, name: via(token))
  end

  def init(token) do
    setup()
    {:ok, %Connection{timeout: @default_timeout, token: token}}
  end

  defp setup do
    GenServer.cast(self(), :setup)
  end

  defp move_to(state) do
    GenServer.cast(self(), state)
  end

  defp via(token) do
    {:via, Registry, {Discord.Gateway.Registry, {__MODULE__, token}}}
  end

  def handle_cast(:setup, %Connection{token: token} = state) do
    gateway_url = case Session.find(token) do
      {:ok, %Session{url: url}} -> url
      {:error, :not_found} -> fetch_gateway_url(token)
    end

    socket = connect(token, gateway_url)

    move_to(:wait_for_hello)

    {:noreply, %Connection{state | socket: socket, url: gateway_url}}
  end

  def handle_cast(:wait_for_hello, state) do
    %Hello{heartbeat_interval: interval_in_ms} = next_message(state.socket, state.timeout)
    start_hearbeat(state.token, state.socket, interval_in_ms)

    if Session.exists?(state.token) do
      move_to(:resume)
    else
      move_to(:identify)
    end

    {:noreply, %Connection{state | timeout: timeout_from_hearbeat_interval(interval_in_ms)}}
  end

  def handle_cast(:identify, state) do
    send_message(state.socket, Identify.with_token(state.token))
    move_to(:receive_loop)

    {:noreply, state}
  end

  def handle_cast(:resume, state) do
    {:ok, session} = Session.find(state.token)
    send_message(state.socket, Resume.from_session(session))
    move_to(:receive_loop)

    {:noreply, state}
  end

  def handle_cast(:receive_loop, %Connection{} = state) do
    next_message(state.socket, state.timeout)
    |> process_message(state)

    move_to(:receive_loop)

    {:noreply, state}
  end

  defp fetch_gateway_url(token) do
    {:ok, websocket_url} = API.Gateway.url(token)
    websocket_url
  end

  defp connect(token, url) do
    uri = URI.parse(url)

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

  defp start_hearbeat(token, socket, interval_in_ms) do
    Logger.info "Starting heartbeats every #{interval_in_ms}ms"
    {:ok, _} = Task.start_link(fn -> beat(token, socket, interval_in_ms) end)
  end

  defp beat(token, socket, interval_in_ms) do
    heartbeat = token
                |> Session.last_seq_received
                |> Heartbeat.new

    send_message(socket, heartbeat)
    :timer.sleep(interval_in_ms)

    beat(token, socket, interval_in_ms)
  end

  defp process_message(%HeartbeatAck{}, _state) do
  end

  defp process_message(%InvalidSession{resumable: false}, state) do
    Session.destroy(state.token)
    Socket.Web.close(state.socket)
  end

  defp process_message(%InvalidSession{resumable: true}, _state) do
    move_to(:resume)
  end

  defp process_message(%Reconnect{}, state) do
    Socket.Web.close(state.socket)
  end

  defp process_message({{"READY", %{"session_id" => session_id}} = event, seq}, state) do
    Session.store(state.token, state.url, session_id, seq)
    Broker.dispatch(state.token, event)
  end

  defp process_message({event, seq}, state) do
    Session.update_seq(state.token, seq)
    Broker.dispatch(state.token, event)
  end
end
