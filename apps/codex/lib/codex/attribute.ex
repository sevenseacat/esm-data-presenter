defmodule Codex.Attribute do
  @moduledoc """
  The hardcoded set of eight attributes that represent a character's basic statistics.

  These attributes are: Strength, Intelligence, Willpower, Agility, Speed, Personality, Endurance,
  and Luck.
  """

  use Ecto.Schema

  @primary_key {:id, :id, autogenerate: false}

  schema "attributes" do
    field(:name)
  end
end
