defmodule Codex.Book do
  @moduledoc """
  Represents a physical book or scroll object placed within the game world. This includes single-use
  spell scrolls.

  The main item of interest for books is the content within the book, though some may also award
  skill points on first reading.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}
  @required_fields [:id, :name, :weight, :value, :model]

  schema "objects" do
    field :name
    field :weight, :decimal
    field :value, :integer
    field :type, :string, default: "book"

    field :model
    field :scroll, :boolean
    field :enchantment_points, :integer
    field :icon
    field :text

    belongs_to :skill, Codex.Skill
    belongs_to :enchantment, Codex.Enchantment, type: :string
    belongs_to :script, Codex.Script, type: :string
  end

  @spec changeset(map) :: %Ecto.Changeset{valid?: boolean}
  def changeset(params) do
    %Codex.Book{}
    |> cast(params, @required_fields ++ [:scroll, :enchantment_points, :icon, :text, :skill_id,
      :enchantment_id, :script_id])
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:skill_id)
    |> foreign_key_constraint(:enchantment_id)
    |> foreign_key_constraint(:script_id)
  end
end
