defmodule Dota2LiveBot.Command do
  @greeting "Hello! I am live and ready to serve you :ok_hand:"
  @help """
  I provide you with regular updates of ongoing competitive Dota2 games.
  By subscribing to a game, you will receive the state of the game every 5
  minutes until the game is over or you unsubscribe.

  __Available commands__

    **d2l:list**
        lists currently live games

    **d2l:sub:$game_id**
        subscribe to the given game

    **d2l:unsub:$game_id**
        unsubscribe from the given game

    **d2l:help**
        prints this help message
  """
  @live_game_list_header """
  __Live Dota2 games__

  """
  @subscription_ack "You are now *subscribed* to the following game:\n\n"
  @unsubscription_ack "You are now *unsubscribed* from the following game:\n\n"

  @game_not_found "Sorry, I could not find a live game with the given ID."
  @malformed_game_id "Sorry, I could not understand the game ID you've provided."
  @unknown "I'm not sure what you mean. Try *d2l:help*."

  alias Steam.Dota2.Game
  alias Dota2LiveBot.Game.Cache
  alias Dota2LiveBot.{DiscordGameFormatter, Subscription}

  def greeting(token, channel_id) do
    Discord.API.Channel.create_message(token, channel_id, @greeting)
  end

  def help(token, channel_id) do
    Discord.API.Channel.create_message(token, channel_id, @help)
  end

  def subscribe(token, channel_id, game_id) do
    case Cache.find_game(game_id) do
      {:ok, %Game{} = game} ->
        Subscription.subscribe(channel_id, game_id)

        content = @subscription_ack <> DiscordGameFormatter.format(game)
        Discord.API.Channel.create_message(token, channel_id, content)
      _ -> Discord.API.Channel.create_message(token, channel_id, @game_not_found)
    end
  end

  def unsubscribe(token, channel_id, game_id) do
    case Cache.find_game(game_id) do
      {:ok, %Game{} = game} ->
        Subscription.unsubscribe(channel_id, game_id)

        content = @unsubscription_ack <> DiscordGameFormatter.format(game)
        Discord.API.Channel.create_message(token, channel_id, content)
      _ -> Discord.API.Channel.create_message(token, channel_id, @game_not_found)
    end
  end

  def live(token, channel_id) do
    content = Cache.live_games
              |> Enum.filter(&Game.professional?/1)
              |> Enum.map(&DiscordGameFormatter.format/1)
              |> format_live_game_list

    Discord.API.Channel.create_message(token, channel_id, content)
  end

  def unknown(token, channel_id) do
    Discord.API.Channel.create_message(token, channel_id, @unknown)
  end

  def malformed_game_id(token, channel_id) do
    Discord.API.Channel.create_message(token, channel_id, @malformed_game_id)
  end

  defp format_live_game_list([]) do
    @live_game_list_header <> "There are no live competitive game right now!"
  end

  defp format_live_game_list(game_descriptions) do
    @live_game_list_header <> (game_descriptions |> Enum.join("\n\n"))
  end
end
