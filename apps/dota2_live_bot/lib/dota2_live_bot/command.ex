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

  def greeting(token, channel_id) do
    Discord.API.Channel.create_message(token, channel_id, @greeting)
  end

  def help(token, channel_id) do
    Discord.API.Channel.create_message(token, channel_id, @help)
  end
end
