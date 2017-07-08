defmodule Dota2LiveBot.DiscordEventConsumer do
  use GenStage

  require Logger

  @greeting "Hello! I am live and ready to serve you :ok_hand:"

  def start_link(token) do
    GenStage.start_link(__MODULE__, token, [])
  end

  def init(token) do
    {:consumer, token, subscribe_to: [Discord.Gateway.Broker.via(token)]}
  end

  def handle_events(events, _from, token) do
    for event <- events do
      handle_event(event, token)
    end

    {:noreply, [], token}
  end

  defp handle_event({"GUILD_CREATE", %{"id" => channel_id}}, token) do
    Discord.API.Channel.create_message(token, channel_id, @greeting)
  end

  defp handle_event({"MESSAGE_CREATE", %{"id" => channel_id}}, token) do
    # Magic happens here
  end

  defp handle_event({_type, _data}, _token) do
  end
end
