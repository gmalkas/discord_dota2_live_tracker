defmodule Discord.Gateway.Protocol.Heartbeat do
  defstruct [:last_seq_received]

  alias __MODULE__

  def new(last_seq_received) do
    %Heartbeat{last_seq_received: last_seq_received}
  end
end
