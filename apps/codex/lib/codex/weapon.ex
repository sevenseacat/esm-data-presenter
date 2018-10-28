defmodule Codex.Weapon do
  @moduledoc """
  Represents an in-game weapon that can be wielded by the player character or an NPC in the game
  world, to deal damage during combat.

  There are many different types of weapons - most are melee, but some are ranged and use
  projectiles, also considered to be weapons in their own right.

  Bare fists (when no weapon is equipped) can also be used in combat, but are not listed here.
  """
  use Ecto.Schema
  import Ecto.{Changeset, Query}

  @primary_key {:id, :string, autogenerate: false}
  @required_fields ~w(id name weight value model enchantment_points type health chop_min chop_max
    slash_min slash_max thrust_min thrust_max reach speed)a
  @object_type "weapon"
  @weapon_types ~w(arrow axe_1_hand axe_2_hand blunt_1_hand blunt_2_hand_close blunt_2_hand_wide
    bolt bow crossbow long_blade_1_hand long_blade_2_hand short_blade_1_hand spear thrown)

  schema "objects" do
    field(:name)
    field(:weight, :decimal)
    field(:value, :integer)
    field(:object_type, :string, default: @object_type)
    field(:model)
    field(:icon)

    field(:chop_min, :integer)
    field(:chop_max, :integer)
    field(:thrust_min, :integer)
    field(:thrust_max, :integer)
    field(:slash_min, :integer)
    field(:slash_max, :integer)
    field(:enchantment_points, :integer)
    field(:type, :string)
    field(:health, :integer)
    field(:speed, :decimal)
    field(:reach, :decimal)
    field(:ignore_resistance, :boolean)
    field(:silver, :boolean)

    belongs_to(:enchantment, Codex.Enchantment, type: :string)
    belongs_to(:script, Codex.Script, type: :string)
  end

  def all, do: from(o in __MODULE__, where: o.object_type == @object_type)

  def changeset(params) do
    %Codex.Weapon{}
    |> cast(params, [
      :enchantment_id,
      :script_id,
      :silver,
      :ignore_resistance,
      :icon
      | @required_fields
    ])
    |> validate_required(@required_fields)
    |> validate_number(:weight, greater_than_or_equal_to: 0)
    |> validate_number(:value, greater_than_or_equal_to: 0)
    |> validate_number(:enchantment_points, greater_than_or_equal_to: 0)
    |> validate_number(:health, greater_than_or_equal_to: 0)
    |> validate_number(:chop_min, greater_than_or_equal_to: 0)
    |> validate_number(:chop_max, greater_than_or_equal_to: 0)
    |> validate_number(:slash_min, greater_than_or_equal_to: 0)
    |> validate_number(:slash_max, greater_than_or_equal_to: 0)
    |> validate_number(:thrust_min, greater_than_or_equal_to: 0)
    |> validate_number(:thrust_max, greater_than_or_equal_to: 0)
    |> validate_number(:reach, greater_than_or_equal_to: 0)
    |> validate_number(:speed, greater_than_or_equal_to: 0)
    |> validate_inclusion(:type, @weapon_types)
    |> unique_constraint(:id, name: :objects_pkey)
    |> foreign_key_constraint(:enchantment_id)
    |> foreign_key_constraint(:script_id)
  end
end
