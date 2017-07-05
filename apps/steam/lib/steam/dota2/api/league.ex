defmodule Steam.Dota2.API.League do
  alias Steam.Dota2.{API, Game, League}

  def all(api_key) do
    case API.get(api_key, leagues_path()) do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, body |> parse_body |> parse_response}
      error -> error
    end
  end

  def live_games(api_key) do
    case API.get(api_key, live_league_games_path()) do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, body |> parse_body |> parse_response}
      error -> error
    end
  end

  def build_league(league) do
    %League{
      id: league["leagueid"],
      name: league["name"],
      description: league["description"],
      itemdef: league["itemdef"],
      tournament_url: league["tournament_url"],
    }
  end

  def build_game(game) do
    %Game{
      id: game["league_game_id"],
      number: game["game_number"],
      league_id: game["league_id"],
      match_id: game["match_id"],
      dire_series_wins: game["dire_series_wins"],
      radiant_series_wins: game["radiant_series_wins"],
      scoreboard: game["scoreboard"],
      radiant_team: game["radiant_team"],
      dire_team: game["dire_team"]
    }
  end

  defp parse_body(body) do
    Poison.decode!(body)
  end

  defp parse_response(%{"result" => %{"leagues" => leagues}}) do
    leagues
    |> Enum.map(&build_league/1)
  end

  defp parse_response(%{"result" => %{"games" => games}}) do
    games
    |> Enum.map(&build_game/1)
  end

  def leagues_path do
    "/GetLeagueListing/v1"
  end

  def live_league_games_path do
    "/GetLiveLeagueGames/v1"
  end
end
