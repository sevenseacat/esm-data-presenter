defmodule Codex.Armor do
  @moduledoc """
  Represents a piece of armor worn on the body of a character in the game world. Both NPCs and the
  player character can equip armor.

  Armor offers protection against attacks in combat, and comes in different types to cover different
  body parts. It also has three weight classes - light, medium and heavy.
  """
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
    field :weight_class

    belongs_to :enchantment, Codex.Enchantment, type: :string
    belongs_to :script, Codex.Script, type: :string
  end

  def weight_class(%{type: type, weight: weight}) when type in @armor_types do
    [medium, heavy] = %{
      ["boots"] => [12.0, 18.0],
      ["cuirass"] => [18.0, 27.0],
      ["greaves", "shield"] => [9.0, 13.5],
      ["left_bracer", "right_bracer", "left_gauntlet", "right_gauntlet", "helmet"] => [3.0, 4.5],
      ["left_pauldron", "right_pauldron"] => [6.0, 9.0]
    }
    |> Enum.find(fn {types, _} -> Enum.member?(types, type) end)
    |> elem(1)

    cond do
      weight <= medium -> "light"
      weight <= heavy  -> "medium"
      true             -> "heavy"
    end
  end
  def weight_class(%{type: type}), do: raise "unknown armor type '#{type}'"

  def changeset(params) do
    %Codex.Armor{}
    |> cast(params, [:enchantment_id, :script_id | @required_fields])
    |> add_weight_class(params)
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

  # If supplying a new type and weight, we must calculate the weight class.
  defp add_weight_class(changeset, %{type: _, weight: _} = params) do
    put_change(changeset, :weight_class, weight_class(params))
  end
  defp add_weight_class(changeset, _params), do: changeset
end
