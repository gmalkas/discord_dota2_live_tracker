defmodule Discord.Gateway.Protocol.Resume do
  defstruct [:token, :session_id, :seq]

  alias Discord.Gateway.Session
  alias __MODULE__

  def from_session(%Session{id: session_id, token: token, seq: seq}) do
    %Resume{
      token: token,
      session_id: session_id,
      seq: seq
    }
  end
end

