defmodule Codex.Enchantment.Effect do
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

  @required_fields [:area, :duration, :magnitude_min, :magnitude_max, :type, :magic_effect_id]
  @effect_types ~w(self touch target)

  schema "enchantment_effects" do
    field :area, :integer
    field :duration, :integer
    field :magnitude_min, :integer
    field :magnitude_max, :integer
    field :type

    belongs_to :enchantment, Codex.Enchantment, type: :string
    belongs_to :attribute, Codex.Attribute
    belongs_to :magic_effect, Codex.MagicEffect
    belongs_to :skill, Codex.Skill
  end

  @spec changeset(map) :: Ecto.Changeset.t
  def changeset(params) do
    %Codex.Enchantment.Effect{}
    |> cast(params, [:enchantment_id])
    |> validate_required(:enchantment_id)
    |> changeset(params)
  end

  @spec changeset(%Codex.Enchantment.Effect{}, map) :: Ecto.Changeset.t
  def changeset(schema, params) do
    schema
    |> cast(params, [:attribute_id, :skill_id | @required_fields])
    |> validate_required(@required_fields)
    |> validate_inclusion(:type, @effect_types)
    |> validate_number(:duration, greater_than_or_equal_to: 0)
    |> validate_number(:magnitude_min, greater_than_or_equal_to: 0)
    |> validate_number(:magnitude_max, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:enchantment_id)
    |> foreign_key_constraint(:attribute_id)
    |> foreign_key_constraint(:magic_effect_id)
    |> foreign_key_constraint(:skill_id)
  end
end
