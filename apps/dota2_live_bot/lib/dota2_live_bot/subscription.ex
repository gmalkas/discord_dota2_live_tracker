defmodule Dota2LiveBot.Subscription do
  use GenServer

  @table_name :dota2_live_bot_subscriptions

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    table = :ets.new(@table_name, [:named_table])
    {:ok, table}
  end

  def subscribe(channel_id, {:league, _league_id} = subscription) do
    GenServer.call(__MODULE__, {:subscribe, channel_id, subscription})
  end

  def subscribe(channel_id, {:game, _game_id} = subscription) do
    GenServer.call(__MODULE__, {:subscribe, channel_id, subscription})
  end

  def unsubscribe(channel_id, {:league, _league_id} = subscription) do
    GenServer.call(__MODULE__, {:unsubscribe, channel_id, subscription})
  end

  def unsubscribe(channel_id, {:game, _game_id} = subscription) do
    GenServer.call(__MODULE__, {:unsubscribe, channel_id, subscription})
  end

  def handle_call({:subscribe, channel_id, subscription}, _from, table) do
    {:reply, :ok, table}
  end
end
