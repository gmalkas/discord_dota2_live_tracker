defmodule Dota2LiveBot.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    discord_token = "DISCORD_BOT_TOKEN" |> System.get_env
    steam_api_key = "STEAM_API_KEY" |> System.get_env

    children = [
      #worker(Dota2LiveBot.Subscription, [discord_token]),
      worker(Dota2LiveBot.Game.Cache, []),
      worker(Dota2LiveBot.Game.Tracker, [steam_api_key]),
      supervisor(Discord.Gateway, [discord_token]),
      worker(Dota2LiveBot.DiscordEventConsumer, [discord_token]),
    ]

    opts = [strategy: :one_for_one, name: Dota2LiveBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
