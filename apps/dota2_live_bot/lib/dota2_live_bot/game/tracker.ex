defmodule Dota2LiveBot.Game.Tracker do
  use GenServer

  @game_refresh_interval :timer.seconds(60)
  @league_refresh_interval :timer.minutes(5)

  alias Dota2LiveBot.Game.Cache

  def start_link(api_key) do
    GenServer.start_link(__MODULE__, api_key, name: __MODULE__)
  end

  def init(api_key) do
    :timer.send_interval(@league_refresh_interval, :refresh_leagues)
    :timer.send_interval(@game_refresh_interval, :refresh_live_games)
    GenServer.cast(__MODULE__, :refresh_leagues)
    GenServer.cast(__MODULE__, :refresh_live_games)

    {:ok, api_key}
  end

  def handle_cast(:refresh_live_games, api_key) do
    refresh_live_games(api_key)
    {:noreply, api_key}
  end

  def handle_cast(:refresh_leagues, api_key) do
    refresh_leagues(api_key)
    {:noreply, api_key}
  end

  def handle_info(:refresh_live_games, api_key) do
    refresh_live_games(api_key)
    {:noreply, api_key}
  end

  def handle_info(:refresh_leagues, api_key) do
    refresh_leagues(api_key)
    {:noreply, api_key}
  end

  defp refresh_leagues(api_key) do
    {:ok, leagues} = Steam.Dota2.API.League.all(api_key)
    Cache.store_leagues(leagues)
  end

  defp refresh_live_games(api_key) do
    {:ok, live_games} = Steam.Dota2.API.League.live_games(api_key)
    Cache.store_live_games(live_games)
  end
end
