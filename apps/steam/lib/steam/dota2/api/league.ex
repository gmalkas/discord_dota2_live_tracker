defmodule Steam.Dota2.API.League do
  alias Steam.Dota2.{API, League}

  def all(api_key) do
    case API.get(api_key, leagues_path()) do
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

  defp parse_body(body) do
    Poison.decode!(body)
  end

  defp parse_response(%{"result" => %{"leagues" => leagues}}) do
    leagues
    |> Enum.map(&build_league/1)
  end

  def leagues_path do
    "/GetLeagueListing/v1"
  end
end
