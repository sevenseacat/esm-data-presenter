defmodule Codex.Apparatus do
  @moduledoc """
  In-game physical tools used in alchemy, for creating potions.

  There are four types of alchemy apparatus, but only one is required for crafting - the mortar and
  pestle. Having each of the other three will improve the quality of the resulting positons.
  """

  use Ecto.Schema
  import Ecto.{Changeset, Query}

  @primary_key {:id, :string, autogenerate: false}
  @required_fields ~w(id name weight value model icon type quality)a
  @object_type "apparatus"
  @apparatus_types ~w(mortar_pestle retort calcinator alembic)

  schema "objects" do
    field :name
    field :weight, :decimal
    field :value, :integer
    field :object_type, :string, default: @object_type
    field :model
    field :icon

    field :type, :string
    field :quality, :decimal
  end

  def all, do: from o in __MODULE__, where: o.object_type == @object_type

  @spec changeset(map) :: %Ecto.Changeset{valid?: boolean}
  def changeset(params) do
    %Codex.Apparatus{}
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> validate_number(:weight, greater_than_or_equal_to: 0)
    |> validate_number(:value, greater_than_or_equal_to: 0)
    |> validate_number(:quality, greater_than: 0)
    |> validate_inclusion(:type, @apparatus_types)
    |> unique_constraint(:id, name: :objects_pkey)
  end
end
