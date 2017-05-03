defmodule Codex.Class do
  @moduledoc """
  Every character in the game, playable or NPC, has an associated Class. This determines their
  initial most powerful attributes and skills.

  For non-playable characters, their class also determines their functionality - whether or not
  they are merchants, what types of items they sell, and what other services they offer.
  """

  use Ecto.Schema
  import Ecto.{Changeset, Query}
  alias Codex.Repo

  @primary_key {:id, :string, autogenerate: false}
  @required_fields [:id, :attribute_1_id, :attribute_2_id, :playable, :specialization_id, :services,
    :vendors]

  schema "classes" do
    field :name
    field :description
    field :playable, :boolean
    field :services, :map
    field :vendors, :map

    belongs_to :specialization, Codex.Specialization
    belongs_to :attribute_1, Codex.Attribute
    belongs_to :attribute_2, Codex.Attribute

    many_to_many :minor_skills, Codex.Skill, join_through: "minor_class_skills"
    many_to_many :major_skills, Codex.Skill, join_through: "major_class_skills"
  end

  def changeset(params) do
    %Codex.Class{}
    |> cast(params, [:description, :name | @required_fields])
    |> validate_required(@required_fields)
    |> add_class_skills(params, :major)
    |> add_class_skills(params, :minor)
    |> unique_constraint(:id, name: :classes_pkey)
    |> foreign_key_constraint(:attribute_1_id)
    |> foreign_key_constraint(:attribute_2_id)
  end

  defp add_class_skills(changeset, params, type) do
    skill_ids = Map.get(params, String.to_atom("#{type}_skill_ids"), [])
    assoc_name = String.to_atom("#{type}_skills")
    skills = Repo.all(from s in Codex.Skill, where: s.id in ^skill_ids)

    changeset
    |> put_assoc(assoc_name, skills)
    |> validate_length(assoc_name, is: 5)
  end
end
