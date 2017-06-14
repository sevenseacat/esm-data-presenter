defmodule Codex.MiscItem do
  @moduledoc """
  Represents a generic item in the game world that doesn't fit into any other category.

  Items classified as 'misc' include gold, soul gems, cutlery/silverware, bottles, keys, pillows...
  """
  use Ecto.Schema
  import Ecto.{Changeset, Query}

  @primary_key {:id, :string, autogenerate: false}
  @required_fields ~w(id name weight value model icon)a
  @object_type "misc"

  schema "objects" do
    field :name
    field :weight, :decimal
    field :value, :integer
    field :object_type, :string, default: @object_type
    field :model
    field :icon

    belongs_to :enchantment, Codex.Enchantment, type: :string
    belongs_to :script, Codex.Script, type: :string
  end

  def all, do: from o in __MODULE__, where: o.object_type == @object_type

  def changeset(params) do
    %Codex.MiscItem{}
    |> cast(params, [:enchantment_id, :script_id | @required_fields])
    |> validate_required(@required_fields)
    |> validate_number(:weight, greater_than_or_equal_to: 0)
    |> validate_number(:value, greater_than_or_equal_to: 0)
    |> unique_constraint(:id, name: :objects_pkey)
    |> foreign_key_constraint(:enchantment_id)
    |> foreign_key_constraint(:script_id)
  end
end
