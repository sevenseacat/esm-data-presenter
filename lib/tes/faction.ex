defmodule Tes.Faction do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}
  @required_fields [:id, :name, :hidden, :attribute_1_id, :attribute_2_id]

  schema "factions" do
    field :name
    field :hidden, :boolean

    belongs_to :attribute_1, Tes.Attribute
    belongs_to :attribute_2, Tes.Attribute
    has_many :ranks, Tes.Faction.Rank
    has_many :reactions, Tes.Faction.Reaction, foreign_key: :source_id
    many_to_many :favorite_skills, Tes.Skill, join_through: :faction_favorite_skills
  end

  def changeset(params) do
    %Tes.Faction{}
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:attribute_1_id)
    |> foreign_key_constraint(:attribute_2_id)
    |> cast_assoc(:ranks)
    |> cast_assoc(:reactions)
  end
end
