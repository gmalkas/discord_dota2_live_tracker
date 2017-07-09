defmodule Dota2LiveBot.Subscription do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    {:ok, %{}}
  end

  def subscribe(channel_id, game_id) do
    GenServer.call(__MODULE__, {:subscribe, channel_id, game_id})
  end

  def unsubscribe(channel_id, game_id) do
    GenServer.call(__MODULE__, {:unsubscribe, channel_id, game_id})
  end

  def handle_call({:subscribe, channel_id, game_id}, _from, subscriptions) do
    new_subs = Map.update(subscriptions, channel_id, MapSet.new, &(MapSet.put(&1, game_id)))

    {:reply, :ok, new_subs}
  end

  def handle_call({:unsubscribe, channel_id, game_id}, _from, subscriptions) do
    new_subs = Map.update(subscriptions, channel_id, MapSet.new, &(MapSet.delete(&1, game_id)))

    {:reply, :ok, new_subs}
  end
end
