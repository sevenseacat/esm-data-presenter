defmodule Tes.Book do
  @moduledoc """
  Represents a physical book or scroll object placed within the game world. This includes single-use
  spell scrolls.

  The main item of interest for books is the content within the book, though some may also award
  skill points on first reading.
  """

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

  @spec changeset(map) :: %Ecto.Changeset{valid?: boolean}
  def changeset(params) do
    %Tes.Book{}
    |> cast(params, @required_fields ++ [:scroll, :enchantment_name, :enchantment_points,
        :texture, :text])
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:skill_id)
  end
end
