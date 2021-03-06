defmodule Codex.AppliedMagicEffect do
  @moduledoc """
  Applied magic effects are magic effects instantiated and applied, such as in a spell, enchantment,
  or potion.

  Each item can have one or more effects applied, and each effect can have its own attributes
  such as duration, magnitude or area.

  For example, an enchanted ring could have an effect with Water Breathing, magnitude 20 points,
  for 30 seconds when used, and also an effect with Fortify Attribute (Luck), magnitude 5 points,
  constant effect.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @required_fields ~w(area duration magnitude_min magnitude_max type magic_effect_id)a
  @effect_types ~w(self touch target)

  schema "applied_magic_effects" do
    field(:area, :integer)
    field(:duration, :integer)
    field(:magnitude_min, :integer)
    field(:magnitude_max, :integer)
    field(:type)

    belongs_to(:attribute, Codex.Attribute)
    belongs_to(:magic_effect, Codex.MagicEffect)
    belongs_to(:skill, Codex.Skill)

    belongs_to(:enchantment, Codex.Enchantment, type: :string)
    belongs_to(:potion, Codex.Potion, type: :string)
    belongs_to(:spell, Codex.Spell, type: :string)
  end

  @spec changeset(%Codex.AppliedMagicEffect{}, map) :: Ecto.Changeset.t()
  def changeset(schema \\ %Codex.AppliedMagicEffect{}, params) do
    schema
    |> cast(params, [:attribute_id, :skill_id | @required_fields])
    |> validate_required(@required_fields)
    |> validate_inclusion(:type, @effect_types)
    |> ensure_only_one_association_specified
    |> validate_number(:duration, greater_than_or_equal_to: 0)
    |> validate_number(:magnitude_min, greater_than_or_equal_to: 0)
    |> validate_number(:magnitude_max, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:enchantment_id)
    |> foreign_key_constraint(:attribute_id)
    |> foreign_key_constraint(:magic_effect_id)
    |> foreign_key_constraint(:skill_id)
  end

  defp ensure_only_one_association_specified(
         %Ecto.Changeset{changes: %{skill_id: skill_id, attribute_id: attribute_id}} = changeset
       )
       when is_integer(skill_id) and is_integer(attribute_id) do
    add_error(changeset, :skill_id, "must be nil if an attribute ID is also provided")
  end

  defp ensure_only_one_association_specified(changeset), do: changeset
end
