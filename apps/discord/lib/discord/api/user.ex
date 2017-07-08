defmodule Discord.API.User do
  @root_path "/users"
  @me_path "#{@root_path}/@me"
  @guilds_path "#{@me_path}/guilds"

  alias Discord.API

  def me(token) do
    case API.get(token, @me_path) do
      {:ok, %HTTPoison.Response{body: body}} ->
        body |> decode_body |> parse_response
      error -> error
    end
  end

  def guilds(token) do
    case API.get(token, @guilds_path) do
      {:ok, %HTTPoison.Response{body: body}} ->
        body |> decode_body |> parse_response
      error -> error
    end
  end

  defp decode_body(body) do
    Poison.decode(body)
  end

  defp parse_response({:ok, response}) do
    {:ok, response}
  end
  defp parse_response(_), do: {:error, "Could not parse response"}
end
