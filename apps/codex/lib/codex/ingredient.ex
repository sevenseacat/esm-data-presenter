defmodule Codex.Ingredient do
  @moduledoc """
  Ingredients are used in alchemy, to craft potions. Each ingredient has four different magic
  effects that can possibly be transferred to the created potion.

  Organic ingredients can mostly be found in the wild by examining plants, and all ingredients can
  be typically be purchased from alchemists.
  """

  use Ecto.Schema
  import Ecto.{Changeset, Query}

  @primary_key {:id, :string, autogenerate: false}
  @required_fields ~w(id name weight value model icon)a
  @object_type "ingredient"

  schema "objects" do
    field(:name)
    field(:weight, :decimal)
    field(:value, :integer)
    field(:object_type, :string, default: @object_type)
    field(:model)
    field(:icon)

    belongs_to(:script, Codex.Script, type: :string)
    has_many(:ingredient_effects, Codex.Ingredient.Effect)
  end

  def all, do: from(o in __MODULE__, where: o.object_type == @object_type)

  def changeset(params) do
    %Codex.Ingredient{}
    |> cast(params, [:script_id | @required_fields])
    |> validate_required(@required_fields)
    |> validate_number(:weight, greater_than_or_equal_to: 0)
    |> validate_number(:value, greater_than_or_equal_to: 0)
    |> unique_constraint(:id, name: :objects_pkey)
    |> foreign_key_constraint(:script_id)
    |> cast_assoc(:ingredient_effects)
  end
end
