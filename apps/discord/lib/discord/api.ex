defmodule Discord.API do
  @base_url "https://discordapp.com/api"

  def get({:bot_token, token}, path, params \\ []) do
    headers = default_headers() ++ bot_token_authentication_headers(token)

    path
    |> endpoint
    |> HTTPoison.get(headers, params: params)
  end

  def with_bot_token(token) do
    {:bot_token, token}
  end

  defp default_headers do
    [{"User-Agent", "DiscordBot (https://github.com/gmalkas/discord_dota2_live_tracker, 1.0)"}]
  end

  defp bot_token_authentication_headers(token) do
    [{"Authorization", "Bot #{token}"}]
  end

  defp endpoint(path) do
    "#{@base_url}#{path}"
  end
end
