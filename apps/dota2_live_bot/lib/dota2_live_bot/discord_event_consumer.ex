defmodule Dota2LiveBot.DiscordEventConsumer do
  use GenStage

  alias Dota2LiveBot.Command

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
    Command.greeting(token, channel_id)
  end

  defp handle_event({"MESSAGE_CREATE", %{"channel_id" => channel_id, "content" => content}}, token) do
    case content do
      "d2l:help" -> Command.help(token, channel_id)
      "d2l:live" -> Command.live(token, channel_id)
      "d2l:sub:" <> game_id ->
        case game_id |> String.trim |> Integer.parse do
          {clean_game_id, _} -> Command.subscribe(token, channel_id, clean_game_id)
          _ -> Command.malformed_game_id(token, channel_id)
        end
      "d2l:unsub:" <> game_id ->
        case game_id |> String.trim |> Integer.parse do
          {clean_game_id, _} -> Command.unsubscribe(token, channel_id, clean_game_id)
          _ -> Command.malformed_game_id(token, channel_id)
        end
      _ -> :ignore
    end
  end

  defp handle_event({_type, _data}, _token) do
  end
end
