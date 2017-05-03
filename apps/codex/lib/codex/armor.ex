defmodule Codex.Armor do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}
  @required_fields [:id, :name, :weight, :value, :model, :icon, :enchantment_points, :type,
    :armor_rating, :health]
  @armor_types ~w(helmet cuirass left_pauldron right_pauldron greaves boots left_gauntlet
    right_gauntlet shield left_bracer right_bracer)

  schema "objects" do
    field :name
    field :weight, :decimal
    field :value, :integer
    field :object_type, :string, default: "armor"
    field :model
    field :icon

    field :enchantment_points, :integer
    field :type, :string
    field :health, :integer
    field :armor_rating, :integer

    belongs_to :enchantment, Codex.Enchantment, type: :string
    belongs_to :script, Codex.Script, type: :string
  end

  def changeset(params) do
    %Codex.Armor{}
    |> cast(params, [:enchantment_id, :script_id | @required_fields])
    |> validate_required(@required_fields)
    |> validate_number(:weight, greater_than_or_equal_to: 0)
    |> validate_number(:value, greater_than_or_equal_to: 0)
    |> validate_number(:enchantment_points, greater_than_or_equal_to: 0)
    |> validate_number(:health, greater_than_or_equal_to: 0)
    |> validate_number(:armor_rating, greater_than_or_equal_to: 0)
    |> validate_inclusion(:type, @armor_types)
    |> unique_constraint(:id, name: :objects_pkey)
    |> foreign_key_constraint(:enchantment_id)
    |> foreign_key_constraint(:script_id)
  end
end
