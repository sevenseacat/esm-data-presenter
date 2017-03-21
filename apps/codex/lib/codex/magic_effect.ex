defmodule Codex.MagicEffect do
  @moduledoc """
  A base status effect (buff or debuff) that can be applied to the player or to an NPC in the game
  world. Some effects apply generally (such as Water Breathing), while others can apply to specific
  attributes or skills (such as Fortify Attribute).

  Spells, potions, and enchantments can all bestow magic effects on the target, with customizations
  such as magnitude and duration.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [:id, :name, :base_cost, :color, :icon, :enchanting, :spellmaking,
    :negative, :particle_texture, :skill_id, :speed, :size, :size_cap]

  schema "magic_effects" do
    field :name
    field :base_cost, :float
    field :color
    field :description
    field :icon
    field :particle_texture
    field :speed, :float
    field :size, :float
    field :size_cap, :float

    field :enchanting, :boolean  # Whether enchantments can be created with the effect.
    field :spellmaking, :boolean # Whether custom spells can be created with the effect.
    field :negative, :boolean    # ???

    field :area_sound
    field :area_visual
    field :bolt_sound
    field :bolt_visual
    field :cast_sound
    field :cast_visual
    field :hit_sound
    field :hit_visual

    belongs_to :skill, Codex.Skill
  end

  @spec changeset(map) :: %Ecto.Changeset{valid?: boolean}
  def changeset(params) do
    %Codex.MagicEffect{}
    |> cast(params, @required_fields ++ [:description, :area_sound, :area_visual, :bolt_sound,
      :bolt_visual, :cast_sound, :cast_visual, :hit_sound, :hit_visual])
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:skill_id)
  end
end
