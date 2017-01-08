defmodule Tes.Faction.Reaction do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [:target_id, :adjustment]

  schema "faction_reactions" do
    field :adjustment, :integer

    belongs_to :source, Tes.Faction, type: :string
    belongs_to :target, Tes.Faction, type: :string
  end

  def changeset(schema, params) do
    schema
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
  end
end
