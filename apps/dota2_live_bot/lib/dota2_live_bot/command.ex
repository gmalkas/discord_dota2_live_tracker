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

  alias Steam.Dota2.Game
  alias Dota2LiveBot.Game.Cache

  def greeting(token, channel_id) do
    Discord.API.Channel.create_message(token, channel_id, @greeting)
  end

  def help(token, channel_id) do
    Discord.API.Channel.create_message(token, channel_id, @help)
  end

  def live(token, channel_id) do
    content = Cache.live_games
              |> Enum.filter(&Game.professional?/1)
              |> Enum.map(&format_game_description/1)
              |> format_live_game_list

    Discord.API.Channel.create_message(token, channel_id, content)
  end

  defp format_game_description(%Game{} = game) do
    """
    **#{Game.radiant_team_name(game)}** vs. **#{Game.dire_team_name(game)}**
    #{game.series_type} (#{game.radiant_series_wins} - #{game.dire_series_wins}) - #{game.duration} - ##{game.id}

    Kills #{game.radiant_kill_count} #{game.dire_kill_count}
    Net Worth #{game.radiant_net_worth} #{game.dire_net_worth}
    """
  end

  defp format_live_game_list([]) do
    @live_game_list_header <> "There are no live competitive game right now!"
  end

  defp format_live_game_list(game_descriptions) do
    @live_game_list_header <> (game_descriptions |> Enum.join("\n\n"))
  end
end
