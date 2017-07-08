defmodule Discord.Gateway.Broker do
  use GenStage

  def start_link(token) do
    GenStage.start_link(__MODULE__, token, name: via(token))
  end

  def init(_token) do
    {:producer, {:queue.new, 0}, dispatcher: GenStage.BroadcastDispatcher}
  end

  def via(token) do
    {:via, Registry, {Discord.Gateway.Registry, {__MODULE__, token}}}
  end

  def dispatch(token, event) do
    GenStage.call(via(token), {:dispatch, event})
  end

  def handle_call({:dispatch, event}, _from, {queue, demand}) do
    {events, new_state} = dispatch_events(:queue.in(event, queue), demand)
    {:reply, :ok, events, new_state}
  end

  def handle_demand(incoming_demand, {queue, demand}) do
    {events, new_state} = dispatch_events(queue, demand + incoming_demand)
    {:noreply, events, new_state}
  end

  defp dispatch_events(queue, demand, events \\ []) do
    with d when d > 0 <- demand,
         {{:value, event}, queue} <- :queue.out(queue) do
      dispatch_events(queue, demand - 1, [event | events])
    else
      _ -> {Enum.reverse(events), {queue, demand}}
    end
  end
end
