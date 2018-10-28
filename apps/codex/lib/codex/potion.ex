defmodule Codex.Potion do
  @moduledoc """
  Represents a physical, consumable potion in the game world.

  Potions can be purchased from alchemists or created by the player by using alchemy Apparatus.
  Each potion has one or more effects on the player when ingested.
  """

  use Ecto.Schema
  import Ecto.{Changeset, Query}

  @primary_key {:id, :string, autogenerate: false}
  @required_fields ~w(id name weight value model icon)a
  @object_type "potion"

  schema "objects" do
    field(:name)
    field(:weight, :decimal)
    field(:value, :integer)
    field(:object_type, :string, default: @object_type)
    field(:model)
    field(:icon)

    belongs_to(:script, Codex.Script, type: :string)
    has_many(:effects, Codex.AppliedMagicEffect)
  end

  def all, do: from(o in __MODULE__, where: o.object_type == @object_type)

  @spec changeset(map) :: %Ecto.Changeset{valid?: boolean}
  def changeset(params) do
    %Codex.Potion{}
    |> cast(params, [:script_id | @required_fields])
    |> validate_required(@required_fields)
    |> validate_number(:weight, greater_than_or_equal_to: 0)
    |> validate_number(:value, greater_than_or_equal_to: 0)
    |> unique_constraint(:id, name: :objects_pkey)
    |> foreign_key_constraint(:script_id)
    |> cast_assoc(:effects)
  end
end
