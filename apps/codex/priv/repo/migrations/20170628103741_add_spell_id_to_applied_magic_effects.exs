defmodule Codex.Repo.Migrations.AddSpellIdToAppliedMagicEffects do
  use Ecto.Migration

  def change do
    alter table(:applied_magic_effects) do
      add :spell_id, references(:spells, type: :string, on_delete: :delete_all), null: true
    end
  end
end
