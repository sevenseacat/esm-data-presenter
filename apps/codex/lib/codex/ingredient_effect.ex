defmodule Codex.Ingredient.Effect do
  @moduledoc """
  Enchantment effects are customized magic effects.

  Each enchantment can have one or more effects applied, and each effect can have its own attributes
  such as duration, magnitude or area.

  For example, an enchanted ring could have an effect with Water Breathing, magnitude 20 points,
  for 30 seconds when used, and also an effect with Fortify Attribute (Luck), magnitude 5 points,
  constant effect.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [:magic_effect_id]
  @attribute_magic_effect_ids [17, 22, 74, 79, 85]
  @skill_magic_effect_ids [21, 26, 78, 83, 89]

  schema "ingredient_effects" do
    belongs_to :ingredient, Codex.Ingredient, type: :string
    belongs_to :attribute, Codex.Attribute
    belongs_to :magic_effect, Codex.MagicEffect
    belongs_to :skill, Codex.Skill
  end

  @doc """
  This function is used when inserting ingredient effects into the database directly, as opposed to
  creating effects as part of the parent ingredient record.
  """
  @spec changeset(map) :: Ecto.Changeset.t
  def changeset(params) do
    %Codex.Ingredient.Effect{}
    |> cast(params, [:ingredient_id])
    |> validate_required(:ingredient_id)
    |> changeset(params)
  end

  @doc """
  This function is used when creating ingredient effects as part of the parent ingredient record,
  as opposed to inserting effects directly.
  """
  @spec changeset(%Codex.Ingredient.Effect{}, map) :: Ecto.Changeset.t
  def changeset(schema, params) do
    params = strip_invalid_params(params)

    schema
    |> cast(params, [:attribute_id, :skill_id | @required_fields])
    |> validate_required(@required_fields)
    |> ensure_only_one_association_specified
    |> foreign_key_constraint(:enchantment_id)
    |> foreign_key_constraint(:attribute_id)
    |> foreign_key_constraint(:magic_effect_id)
    |> foreign_key_constraint(:skill_id)
  end

  defp ensure_only_one_association_specified(
    %Ecto.Changeset{changes: %{skill_id: skill_id, attribute_id: attribute_id}} = changeset
  ) when is_integer(skill_id) and is_integer(attribute_id) do
    add_error(changeset, :skill_id, "must be nil if an attribute ID is also provided")
  end

  defp ensure_only_one_association_specified(changeset), do: changeset

  defp strip_invalid_params(%{magic_effect_id: effect, skill_id: skill, attribute_id: attribute})
    when effect in @attribute_magic_effect_ids do
    %{magic_effect_id: effect, skill_id: nil, attribute_id: attribute}
  end

  defp strip_invalid_params(%{magic_effect_id: effect, skill_id: skill, attribute_id: attribute})
    when effect in @skill_magic_effect_ids do
    %{magic_effect_id: effect, skill_id: skill, attribute_id: nil}
  end

  defp strip_invalid_params(%{magic_effect_id: effect} = params) do
    %{magic_effect_id: effect, skill_id: nil, attribute_id: nil}
  end
end
