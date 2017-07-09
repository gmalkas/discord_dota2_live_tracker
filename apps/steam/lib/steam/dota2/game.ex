defmodule Steam.Dota2.Game do
  defstruct [:id, :number, :league_id, :dire_series_wins,
             :radiant_series_wins, :scoreboard, :radiant_team,
             :dire_team]
end
