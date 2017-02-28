defmodule Tes.Skill do
  @moduledoc """
  There are 27 hardcoded skills within the in-game world. Each character has a numerical value for
  each of the skills - this represents their proficiency in the skill.

  For magic-related skills, having a higher skill means that casting a related spell has a higher
  success chance. For weapon-related skills, having a higher skill means that using the weapon will
  have a higher chance of connecting.

  Skills level up by using them, eg. by casting spells or by picking locks, or by paying trainer
  NPCs to increase them.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: false}
  @required_fields [:id, :name, :description, :attribute_id, :specialization_id]

  schema "skills" do
    field :name
    field :description

    belongs_to :attribute, Tes.Attribute
    belongs_to :specialization, Tes.Specialization
  end

  @spec changeset(map) :: %Ecto.Changeset{valid?: boolean}
  def changeset(params) do
    %Tes.Skill{}
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:attribute_id)
    |> foreign_key_constraint(:specialization_id)
  end
end
