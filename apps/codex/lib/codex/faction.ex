defmodule Codex.Faction do
  @moduledoc """
  Factions, including guilds and Great Houses, are NPC organisations in the in-game world.

  Typically a character will join one or more factions during a playthrough, and level up through
  the ranks of the faction by doing quests for specific guest-givers in that faction.

  Some factions in the game are not visible to the player, such as the Twin Lamps, but can still be
  joined and faction reputation points awarded.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}
  @required_fields [:id, :name, :hidden, :attribute_1_id, :attribute_2_id]

  schema "factions" do
    field :name
    field :hidden, :boolean

    belongs_to :attribute_1, Codex.Attribute
    belongs_to :attribute_2, Codex.Attribute
    has_many :ranks, Codex.Faction.Rank
    has_many :reactions, Codex.Faction.Reaction, foreign_key: :source_id
    many_to_many :favorite_skills, Codex.Skill, join_through: :faction_favorite_skills
  end

  @spec changeset(map) :: %Ecto.Changeset{valid?: boolean}
  def changeset(params) do
    %Codex.Faction{}
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:attribute_1_id)
    |> foreign_key_constraint(:attribute_2_id)
    |> cast_assoc(:ranks)
    |> cast_assoc(:reactions)
  end
end
