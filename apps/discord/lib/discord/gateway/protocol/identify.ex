defmodule Discord.Gateway.Protocol.Identify do
  defstruct [:token, :compress, :properties, :large_threshold]

  @default_threshold 250

  alias __MODULE__

  def with_token(token) do
    %Identify{
      token: token,
      compress: false,
      properties: %{},
      large_threshold: @default_threshold
    }
  end
end
