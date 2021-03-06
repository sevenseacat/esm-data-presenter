defmodule Codex.Tool do
  @moduledoc """
  In-game physical tools used for nefarious (stealth) purposes. There are three types that share
  identical data:

  * Probes used for disarming traps,
  * Lockpicks used for picking locks, and
  * Repair items used for repairing weapons and armour.
  """

  use Ecto.Schema
  import Ecto.{Changeset, Query}

  @primary_key {:id, :string, autogenerate: false}
  @required_fields ~w(id name weight value model icon type quality uses)a
  @object_type "tool"
  @tool_types ~w(probe lockpick repair)

  schema "objects" do
    field(:name)
    field(:weight, :decimal)
    field(:value, :integer)
    field(:object_type, :string, default: @object_type)
    field(:model)
    field(:icon)

    field(:type, :string)
    field(:quality, :decimal)
    field(:uses, :integer)
  end

  def all, do: from(o in __MODULE__, where: o.object_type == @object_type)

  @spec changeset(map) :: %Ecto.Changeset{valid?: boolean}
  def changeset(params) do
    %Codex.Tool{}
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> validate_number(:weight, greater_than_or_equal_to: 0)
    |> validate_number(:value, greater_than_or_equal_to: 0)
    |> validate_number(:quality, greater_than: 0)
    |> validate_number(:uses, greater_than: 0)
    |> validate_inclusion(:type, @tool_types)
    |> unique_constraint(:id, name: :objects_pkey)
  end
end
