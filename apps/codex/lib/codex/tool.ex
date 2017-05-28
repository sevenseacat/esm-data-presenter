defmodule Codex.Tool do
  @moduledoc """
  In-game physical tools used for nefarious (stealth) purposes. Two types that share identical data:

  * Probes used for disarming traps, and
  * Lockpicks used for picking locks.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}
  @required_fields [:id, :name, :weight, :value, :model, :icon, :type, :quality, :uses]
  @tool_types ~w(probe lockpick repair)

  schema "objects" do
    field :name
    field :weight, :decimal
    field :value, :integer
    field :object_type, :string, default: "tool"
    field :model
    field :icon

    field :type, :string
    field :quality, :decimal
    field :uses, :integer
  end

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
