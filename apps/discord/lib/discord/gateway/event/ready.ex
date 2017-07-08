defmodule Discord.Gateway.Event.Ready do
  defstruct [:session_id, :user, :protocol_version]
end
