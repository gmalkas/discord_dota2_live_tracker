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

  alias Discord.Gateway.Event
  alias Discord.Gateway.Protocol.{
    Heartbeat, HeartbeatAck, Hello, Identify, InvalidSession, Reconnect
  }

  def decode(data) when is_binary(data) do
    data
    |> Poison.decode!
    |> decode
  end

  def decode(%{"op" => @dispatch, "d" => data, "s" => seq, "t" => type}) do
    {:ok, {decode_event(type, data), seq}}
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
    %{op: @identify, d: identify} |> encode
  end

  def encode(%Heartbeat{last_seq_received: seq}) do
    %{op: @heartbeat, d: seq} |> encode
  end

  def encode(message), do: Poison.encode!(message)

  defp decode_event("READY", %{"v" => v, "user" => user, "session_id" => session_id}) do
    %Event.Ready{
      protocol_version: v,
      user: user,
      session_id: session_id
    }
  end

  defp decode_event(type, data) do
    {type, data}
  end
end
