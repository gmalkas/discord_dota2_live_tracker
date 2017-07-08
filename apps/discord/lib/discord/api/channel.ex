defmodule Discord.API.Channel do
  @root_path "/channels"

  alias Discord.API

  def create_message(token, channel_id, content) do
    case API.post(token, create_message_path(channel_id), format_message(content)) do
      {:ok, %HTTPoison.Response{body: body} = resp} -> resp
      error -> error
    end
  end

  defp format_message(message) do
    %{
      content: message,
      file: :content
    }
  end

  defp decode_body(body) do
    Poison.decode(body)
  end

  defp parse_response({:ok, response}) do
    {:ok, response}
  end
  defp parse_response(_), do: {:error, "Could not parse response"}

  defp create_message_path(channel_id) do
    "#{@root_path}/#{channel_id}/messages"
  end
end
