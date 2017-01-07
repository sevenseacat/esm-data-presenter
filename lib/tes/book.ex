defmodule Tes.Book do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}
  @required_fields [:id, :name, :model, :weight, :value]

  schema "books" do
    field :name
    field :model
    field :weight, :decimal
    field :value, :integer
    field :scroll, :boolean
    field :enchantment_name
    field :enchantment_points, :integer
    field :texture
    field :text

    belongs_to :skill, Tes.Skill
  end

  def changeset(params) do
    %Tes.Book{}
    |> cast(params, @required_fields ++ [:scroll, :enchantment_name, :enchantment_points, :texture, :text])
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:skill_id)
  end
end
