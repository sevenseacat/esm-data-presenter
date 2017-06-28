defmodule Codex.Repo.Migrations.CreateSpells do
  use Ecto.Migration

  def change do
    create table(:spells, primary_key: false) do
      add :id, :string, primary_key: true
      add :name, :string, null: false
      add :type, :string, null: false
      add :starting_spell, :boolean, default: false
      add :cost, :integer, null: false
      add :always_succeeds, :boolean, default: false
      add :autocalc, :boolean, default: false
    end
  end
end
