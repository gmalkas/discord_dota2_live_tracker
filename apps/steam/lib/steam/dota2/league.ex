defmodule Steam.Dota2.League do
  defstruct [:id, :description, :name, :tournament_url, :itemdef]

  alias __MODULE__

  def human_readable_name(%League{name: name}) do
    name
    |> String.replace_leading("#DOTA_Item", "")
    |> String.replace("_", " ")
  end
end
