defmodule Tes.Faction.Rank do
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

    belongs_to :faction, Tes.Faction, type: :string
  end

  def changeset(schema, params) do
    schema
    |> cast(params, @required_params)
    |> validate_required(@required_params)
  end
end
