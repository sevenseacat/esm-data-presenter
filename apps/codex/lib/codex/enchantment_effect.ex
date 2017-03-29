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

  @required_fields [:area, :duration, :magnitude_min, :magnitude_max]
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

  @spec changeset(%Codex.Enchantment.Effect{}, map) :: %Ecto.Changeset{valid?: boolean}
  def changeset(schema, params) do
    schema
    |> cast(params, @required_fields ++ [:attribute_id, :magic_effect_id, :skill_id])
    |> put_change(:type, Atom.to_string(params[:type]))
    |> validate_required(@required_fields)
    |> validate_inclusion(:type, @effect_types)
    |> foreign_key_constraint(:attribute_id)
    |> foreign_key_constraint(:effect_id)
    |> foreign_key_constraint(:skill_id)
  end
end
