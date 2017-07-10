defmodule Dota2LiveBot.Game.Announcer do
  use GenServer
  require Logger

  @interval :timer.minutes(5)

  alias Dota2LiveBot.{DiscordGameFormatter, Subscription}
  alias Dota2LiveBot.Game.Cache

  def start_link(token) do
    GenServer.start_link(__MODULE__, token, name: __MODULE__)
  end

  def init(token) do
    :timer.send_interval(@interval, :announce)

    {:ok, token}
  end

  def handle_cast(:announce, token) do
    announce(token)
    {:noreply, token}
  end

  def handle_info(:announce, token) do
    announce(token)
    {:noreply, token}
  end

  defp announce(token) do
    Logger.warn("Sending updates")
    subscriptions = Subscription.all
    live_games_by_id = Cache.live_games
                       |> Enum.reduce(%{}, fn game, games_by_id -> 
                         Map.put(games_by_id, game.id, game)
                       end)
    live_game_ids = live_games_by_id
                    |> Map.keys
                    |> MapSet.new

    Logger.warn("We have #{map_size subscriptions} subscriptions")
    subscriptions
    |> Enum.map(fn {channel_id, game_ids} ->
      {channel_id, game_ids |> MapSet.intersection(live_game_ids) |> MapSet.to_list}
    end)
    |> Enum.each(fn {channel_id, game_ids} ->
      live_games_by_id
      |> Map.take(game_ids)
      |> Map.values
      |> Enum.map(&DiscordGameFormatter.format/1)
      |> Enum.join("\n\n")
      |> send_game_updates(channel_id, token)
    end)
  end

  defp send_game_updates(message, channel_id, token) do
    Discord.API.Channel.create_message(token, channel_id, message)
  end
end
