defmodule Codex.Enchantment do
  @moduledoc """
  Enchantments are applied to items in the game world, to apply one or more magical effects to them.

  They can be applied to a wide variety of items, such as:
  * Pieces of paper (to create scrolls, offensive spells to be used in combat)
  * Clothing (to buff the player's stats or alter their status)
  * Weapons (offensive effects to be used in combat)
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}
  @required_fields [:id, :charge, :cost, :autocalc, :type]
  @enchantment_types ~w(once on_strike when_used constant_effect)

  schema "enchantments" do
    field :type
    field :charge, :integer
    field :cost, :integer
    field :autocalc, :boolean

    has_many :enchantment_effects, Codex.Enchantment.Effect
  end

  @spec changeset(map) :: %Ecto.Changeset{valid?: boolean}
  def changeset(params) do
    %Codex.Enchantment{}
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:type, @enchantment_types)
    |> validate_number(:cost, greater_than_or_equal_to: 0)
    |> validate_number(:charge, greater_than_or_equal_to: 0)
    |> cast_assoc(:enchantment_effects)
  end
end
