defmodule Tes.Skill do
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

  def changeset(params) do
    %Tes.Skill{}
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:attribute_id)
    |> foreign_key_constraint(:specialization_id)
  end
end
