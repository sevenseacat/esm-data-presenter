defmodule Codex.Object do
  @moduledoc """
  A generic physical object in the game world. Items can be in the game world, in a player's/NPC's
  inventory, or in containers.

  This module is useful for looking up collections of disparate object types, eg. 'what items does
  this NPC hold'.
  """

  use Ecto.Schema

  @primary_key {:id, :string, autogenerate: false}

  schema "objects" do
    field :name
    field :weight, :decimal
    field :value, :integer
    field :object_type, :string
    field :model
    field :icon
  end

  def as_references(objects) do
    Enum.map(objects, &as_reference/1)
  end

  def schema_module(type) do
    :"Elixir.Codex.#{type |> String.split("_") |> Enum.map(&(String.capitalize(&1))) |> Enum.join}"
  end

  defp as_reference(object) do
    struct(schema_module(object.object_type), Map.from_struct(object))
  end
end
