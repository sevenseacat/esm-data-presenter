defmodule Codex.Faction.Reaction do
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

    belongs_to :source, Codex.Faction, type: :string
    belongs_to :target, Codex.Faction, type: :string
  end

  @spec changeset(map) :: Ecto.Changeset.t
  def changeset(params) do
    %Codex.Faction.Reaction{}
    |> cast(params, [:source_id])
    |> validate_required(:source_id)
    |> changeset(params)
  end

  @spec changeset(%Codex.Faction.Reaction{}, map) :: Ecto.Changeset.t
  def changeset(schema, params) do
    schema
    |> cast(params, [:adjustment])
    |> put_change(:target_id, Map.get(params, :faction_id))
    |> validate_required(@required_fields)
    |> assoc_constraint(:source)
  end
end
