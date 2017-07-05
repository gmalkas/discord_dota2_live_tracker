defmodule Steam.Dota2.API do
  @dota2_app_id 570
  @root_path "http://api.steampowered.com/IDOTA2Match_#{@dota2_app_id}"

  def get(api_key, path, params \\ []) do
    path
    |> endpoint
    |> HTTPoison.get([], params: Keyword.merge(params, [key: api_key]))
  end

  defp endpoint(path) do
    "#{@root_path}#{path}"
  end
end
