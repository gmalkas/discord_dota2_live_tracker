defmodule Dota2LiveBot.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    token = "DISCORD_BOT_TOKEN" |> System.get_env

    children = [
      #worker(Dota2LiveBot.Subscription, [token]),
      #worker(Dota2LiveBot.Game.Cache, [token]),
      #worker(Dota2LiveBot.Game.Tracker, [token]),
      supervisor(Discord.Gateway, [token]),
      worker(Dota2LiveBot.DiscordEventConsumer, [token]),
    ]

    opts = [strategy: :one_for_one, name: Dota2LiveBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
