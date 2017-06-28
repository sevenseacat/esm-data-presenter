defmodule Codex.Spell do
  @moduledoc """
  Represents a spell that can be 'known' by the player or a NPC. Known spells are reusable, cost
  magicka to cast, and most have a chance of failure (depending on the caster's skill level in the
  spell's governing skill).

  Spells may be given to the player when creating their character, or can be purchased from
  spellmakers.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}
  @required_fields ~w(id name cost type)a
  @spell_types ~w(spell power ability blight disease)

  schema "spells" do
    field :name
    field :cost, :integer
    field :type
    field :always_succeeds, :boolean
    field :autocalc, :boolean
    field :starting_spell, :boolean

    has_many :effects, Codex.AppliedMagicEffect
  end

  def all, do: __MODULE__

  @spec changeset(map) :: %Ecto.Changeset{valid?: boolean}
  def changeset(params) do
    %Codex.Spell{}
    |> cast(params, [:always_succeeds, :autocalc, :starting_spell | @required_fields])
    |> validate_required(@required_fields)
    |> validate_number(:cost, greater_than_or_equal_to: 0)
    |> validate_inclusion(:type, @spell_types)
    |> unique_constraint(:id, name: :spells_pkey)
    |> cast_assoc(:effects)
  end
end
