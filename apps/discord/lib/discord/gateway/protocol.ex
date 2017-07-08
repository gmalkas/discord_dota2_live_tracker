defmodule Discord.Gateway.Protocol do
  @dispatch 0
  @heartbeat 1
  @identify 2
  @status_update 3
  @voice_status_update 4
  @voice_server_ping 5
  @resume 6
  @reconnect 7
  @request_guild_members 8
  @invalid_session 9
  @hello 10
  @heartbeat_ack 11

  alias Discord.Gateway.Protocol.{HeartbeatAck, Hello, Identify, InvalidSession, Reconnect}

  def decode(data) when is_binary(data) do
    data
    |> Poison.decode!
    |> decode
  end

  def decode(%{"op" => @dispatch}) do
  end

  def decode(%{"op" => @reconnect}), do: {:ok, %Reconnect{}}

  def decode(%{"op" => @invalid_session, "d" => resumable}) do
    {:ok, %InvalidSession{resumable: resumable}}
  end

  def decode(%{"op" => @hello, "d" => %{"heartbeat_interval" => interval, "_trace" => trace}}) do
    {:ok, %Hello{heartbeat_interval: interval, _trace: trace}}
  end

  def decode(%{"op" => @heartbeat_ack}), do: {:ok, %HeartbeatAck{}}
  def decode(_), do: {:error, :malformed_message}

  def encode(%Identify{} = identify) do
    Poison.encode!(%{op: @identify, d: identify})
  end
end
