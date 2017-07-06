defmodule Discord.API.Gateway do
  @root_path "/gateway"

  alias Discord.API

  def url(authentication) do
    case API.get(authentication, @root_path) do
      {:ok, %HTTPoison.Response{body: body}} -> body |> decode_body |> parse_response
      error -> error
    end
  end

  defp decode_body(body) do
    Poison.decode(body)
  end

  defp parse_response({:ok, %{"url" => url}}) do
    {:ok, url}
  end
  defp parse_response(_), do: {:error, "Could not parse response"}
end

