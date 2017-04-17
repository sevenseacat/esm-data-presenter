defmodule Codex.Faction.Rank do
  @moduledoc """
  A faction rank represents the level of prestige and power of a character, within a given faction.

  Specific ranks are often used as a requirement for starting various quests, or receiving various
  pieces of dialogue, eg. the second set of quests from Ajira in the Mages Guild cannot be started
  until the player achieves the rank of Warlock in the guild.

  To achieve a rank, the player must have met the requirements of that rank - the level of the
  favorite attributes and skills of the guild, and a certain number of faction reputation points,
  mainly awarded from completing quests.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @required_params [:number, :name, :attribute_1, :attribute_2, :skill_1,
    :skill_2, :reputation]

  schema "faction_ranks" do
    field :number, :integer
    field :name
    field :attribute_1, :integer
    field :attribute_2, :integer
    field :skill_1, :integer
    field :skill_2, :integer
    field :reputation, :integer

    belongs_to :faction, Codex.Faction, type: :string
  end

  @spec changeset(%Codex.Faction.Rank{}, map) :: %Ecto.Changeset{valid?: boolean}
  def changeset(schema \\ %Codex.Faction.Rank{}, params) do
    schema
    |> cast(params, @required_params)
    |> validate_required([:faction_id | @required_params])
    |> foreign_key_constraint(:faction_id)
    |> validate_number(:number, greater_than: 0)
    |> validate_number(:attribute_1, greater_than_or_equal_to: 0)
    |> validate_number(:attribute_2, greater_than_or_equal_to: 0)
    |> validate_number(:skill_1, greater_than_or_equal_to: 0)
    |> validate_number(:skill_2, greater_than_or_equal_to: 0)
    |> validate_number(:reputation, greater_than_or_equal_to: 0)
  end
end
