defmodule Dota2LiveBot.Command do
  @greeting "Hello! I am live and ready to serve you :ok_hand:"
  @help """
  *** Dota2 Live Match Tracker ***
  This Bot allows you to get regular updates on ongoing competitive Dota2 games.
  By subscribing to a game, you will receive the state of the game every 5
  minutes.

  Available commands:
  ------------------

    __d2l:help__:           prints this help message
    __d2l:list__:           lists currently live games
    __d2l:sub:$game_id__:   subscribe to the given game
    __d2l:unsub:$game_id__: unsubscribe from the given game
  ********************************
  """

  def greeting(token, channel_id) do
    Discord.API.Channel.create_message(token, channel_id, @greeting)
  end

  def help(token, channel_id) do
    Discord.API.Channel.create_message(token, channel_id, @help)
  end
end
