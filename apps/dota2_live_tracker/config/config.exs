# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :dota2_live_tracker,
  discord_token: System.get_env("DISCORD_BOT_TOKEN")

# Configures the endpoint
config :dota2_live_tracker, Dota2LiveTracker.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "4r3MdtPkN/1nsfryMi4tXZWxNk7OmzPFmuZEeSJa9PZrhqbAQQQtRU7grnLQrnNz",
  render_errors: [view: Dota2LiveTracker.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Dota2LiveTracker.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
