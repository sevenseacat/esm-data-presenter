defmodule Codex.Clothing do
  @moduledoc """
  Represents a piece of clothing worn on the body of a character in the game world. Both NPCs and
  the player character can equip clothing.

  Clothing offers very limited protection against attacks in combat, and is mainly about appearance
  and enchantment.
  """
  use Ecto.Schema
  import Ecto.{Changeset, Query}

  @primary_key {:id, :string, autogenerate: false}
  @required_fields ~w(id name weight value model enchantment_points type)a
  @object_type "clothing"
  @armor_types ~w(amulet belt left_glove pants right_glove ring robe shirt shoes skirt)

  schema "objects" do
    field(:name)
    field(:weight, :decimal)
    field(:value, :integer)
    field(:object_type, :string, default: @object_type)
    field(:model)
    field(:icon)

    field(:enchantment_points, :integer)
    field(:type, :string)

    belongs_to(:enchantment, Codex.Enchantment, type: :string)
    belongs_to(:script, Codex.Script, type: :string)
  end

  def all, do: from(o in __MODULE__, where: o.object_type == @object_type)

  def changeset(params) do
    %Codex.Clothing{}
    |> cast(params, [:enchantment_id, :script_id, :icon | @required_fields])
    |> validate_required(@required_fields)
    |> validate_number(:weight, greater_than_or_equal_to: 0)
    |> validate_number(:value, greater_than_or_equal_to: 0)
    |> validate_number(:enchantment_points, greater_than_or_equal_to: 0)
    |> validate_inclusion(:type, @armor_types)
    |> unique_constraint(:id, name: :objects_pkey)
    |> foreign_key_constraint(:enchantment_id)
    |> foreign_key_constraint(:script_id)
  end
end
