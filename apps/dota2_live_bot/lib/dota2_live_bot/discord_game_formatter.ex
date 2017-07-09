defmodule Dota2LiveBot.DiscordGameFormatter do
  alias Steam.Dota2.Game

  def format(%Game{} = game) do
    """
    **#{Game.radiant_team_name(game)}** vs. **#{Game.dire_team_name(game)}**
    #{game.series_type} (#{game.radiant_series_wins} - #{game.dire_series_wins}) - #{game.duration} - ##{game.id}

    Kills #{game.radiant_kill_count} #{game.dire_kill_count}
    Net Worth #{game.radiant_net_worth} #{game.dire_net_worth}
    """
  end
end
