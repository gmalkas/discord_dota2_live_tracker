defmodule Dota2LiveBot.Game.Cache do
  use GenServer

  @table_name :dota2_live_bot_game_cache

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    table = :ets.new(@table_name, [:named_table])
    {:ok, table}
  end

  def store_leagues(leagues) do
    GenServer.call(__MODULE__, {:store, :league, leagues})
  end

  def store_live_games(games) do
    GenServer.call(__MODULE__, {:store, :game, games, :live})
  end

  def live_games do
    :ets.match(@table_name, {{:game, :"_"}, :"$1", :live})
    |> List.flatten
  end

  def leagues do
    :ets.match(@table_name, {{:league, :"_"}, :"$1"})
    |> List.flatten
  end

  def find_game(game_id) when is_integer(game_id) do
    case :ets.match(@table_name, {{:game, game_id}, :"$1", :live}) do
      [[game]] -> {:ok, game}
      [] -> {:error, :not_found}
    end
  end

  def handle_call({:store, :game, items, state}, _from, table) do
    items
    |> Enum.each(fn item ->
      :ets.insert(table, {{:game, item.id}, item, state})
    end)

    {:reply, :ok, table}
  end

  def handle_call({:store, type, items}, _from, table) do
    items
    |> Enum.each(fn item ->
      :ets.insert(table, {{type, item.id}, item})
    end)

    {:reply, :ok, table}
  end
end
