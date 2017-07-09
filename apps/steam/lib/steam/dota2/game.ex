defmodule Steam.Dota2.Game do
  defstruct [:id, :league_id, :league_tier,
             :series_type, :dire_series_wins, :radiant_series_wins,
             :radiant_team, :dire_team,
             :radiant_net_worth, :dire_net_worth,
             :radiant_kill_count, :dire_kill_count,
             :duration]

  alias __MODULE__

  def from_live_league_game(%{} = game) do
    %Game{
      id: game["match_id"],
      league_id: game["league_id"],
      league_tier: game["league_tier"],
      series_type: series(game["series_type"]),
      dire_series_wins: game["dire_series_wins"],
      radiant_series_wins: game["radiant_series_wins"],
      radiant_team: game["radiant_team"],
      dire_team: game["dire_team"],
      radiant_net_worth: radiant_net_worth(game["scoreboard"]),
      dire_net_worth: dire_net_worth(game["scoreboard"]),
      radiant_kill_count: radiant_kill_count(game["scoreboard"]),
      dire_kill_count: dire_kill_count(game["scoreboard"]),
      duration: duration(game["scoreboard"])
    }
  end

  def radiant_team_name(%Game{radiant_team: team}), do: team_name(team)
  def dire_team_name(%Game{dire_team: team}), do: team_name(team)

  defp team_name(%{"team_name" => name}), do: name
  defp team_name(nil), do: "Unknown Team"

  def professional?(%Game{league_tier: tier}) do
    tier > 1
  end

  defp duration(nil) do
    "Picks/Bans"
  end

  defp duration(%{"duration" => duration}) do
    {h, m, s, _} = duration
    |> Timex.Duration.from_seconds
    |> Timex.Duration.to_clock

    "#{h}:#{m}:#{s}"
  end

  defp radiant_net_worth(nil), do: 0
  defp radiant_net_worth(%{"radiant" => %{"players" => players}}) do
    sum_on(players, "net_worth")
  end

  defp dire_net_worth(nil), do: 0
  defp dire_net_worth(%{"dire" => %{"players" => players}}) do
    sum_on(players, "net_worth")
  end


  defp radiant_kill_count(nil), do: 0
  defp radiant_kill_count(%{"radiant" => %{"players" => players}}) do
    sum_on(players, "kills")
  end

  defp dire_kill_count(nil), do: 0
  defp dire_kill_count(%{"dire" => %{"players" => players}}) do
    sum_on(players, "kills")
  end

  defp sum_on(players, attr) when is_list(players) do
    players
    |> Enum.reduce(0, fn player, total ->
      total + player[attr]
    end)
  end

  defp series(series_id) do
    case series_id do
      0 -> "Bo1"
      1 -> "Bo3"
      2 -> "Bo5"
      3 -> "Bo7"
      _ -> ""
    end
  end
end
