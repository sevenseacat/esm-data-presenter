defmodule Codex.Script do
  @moduledoc """
  A snippet of code attached to objects in the game world, written in a custom scripting language.

  Scripts are used to give custom behaviour to generic objects, eg.
  * Triggering a journal entry when a book is read
  * Spawning an enemy when an item is picked up
  * Make a NPC more hostile when a condition is met
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}

  schema "scripts" do
    field :text, :string
  end

  @spec changeset(map) :: %Ecto.Changeset{valid?: boolean}
  def changeset(params) do
    %Codex.Script{}
    |> cast(params, [:id, :text])
    |> validate_required([:id, :text])
  end
end
