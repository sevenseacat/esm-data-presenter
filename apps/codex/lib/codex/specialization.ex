defmodule Codex.Specialization do
  @moduledoc """
  Each Skill belongs to one of the three hardcoded specializations - Combat, Magic and Stealth.

  When the player creates a character and chooses a specialization for that character, each of
  the skills that have that same specialization get a +5 starting bonus.
  """

  use Ecto.Schema

  @primary_key {:id, :id, autogenerate: false}

  schema "specializations" do
    field(:name)
  end
end
