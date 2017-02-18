defmodule Tes.Faction.Reaction do
  @moduledoc """
  Records a numerical score between a source faction and each other faction in the game. Generally,
  a score of how much members in the source faction "like" members in the target faction. Negative
  numbers mean "dislike", and positive numbers mean "like".

  This number is used for calculating disposition changes, when talking to NPCs of a given faction.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [:target_id, :adjustment]

  schema "faction_reactions" do
    field :adjustment, :integer

    belongs_to :source, Tes.Faction, type: :string
    belongs_to :target, Tes.Faction, type: :string
  end

  @spec changeset(%Tes.Faction.Reaction{}, map) :: %Ecto.Changeset{valid?: boolean}
  def changeset(schema, params) do
    schema
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
  end
end
