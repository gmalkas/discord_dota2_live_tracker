defmodule Discord.API do
  @base_url "https://discordapp.com/api"

  def get(token, path, params \\ []) do
    path
    |> endpoint
    |> HTTPoison.get(headers(token), params: params)
  end

  def put(token, path, body \\ "", params \\ []) do
    path
    |> endpoint
    |> HTTPoison.put(encode_body(body), headers(token), params: params)
  end

  def post(token, path, body \\ "", params \\ []) do
    path
    |> endpoint
    |> HTTPoison.post(encode_body(body), headers(token), params: params)
  end

  defp encode_body(body), do: Poison.encode!(body)

  def headers(token) do
    default_headers() ++ token_authentication_headers(token)
  end

  defp default_headers do
    [
      {"User-Agent", "DiscordBot (https://github.com/gmalkas/discord_dota2_live_tracker, 1.0)"},
      {"Content-Type", "application/json"}
    ]
  end

  defp token_authentication_headers(token) do
    [{"Authorization", token}]
  end

  defp endpoint(path) do
    "#{@base_url}#{path}"
  end
end
