defmodule Dota2LiveBot.Game.Cache do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    table = :ets.new(:discord_gateway_sessions, [])
    {:ok, table}
  end

  def store_leagues(leagues) do
    GenServer.call(__MODULE__, {:store, :league, leagues})
  end

  def store_games(games) do
    GenServer.call(__MODULE__, {:store, :game, games})
  end

  def handle_call({:store, type, items}, _from, table) do
    items
    |> Enum.each(fn item ->
      :ets.insert(table, {{type, item.id}, item})
    end)

    {:reply, :ok, table}
  end
end
