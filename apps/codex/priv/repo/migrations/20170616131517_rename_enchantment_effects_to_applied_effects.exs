defmodule Codex.Repo.Migrations.RenameEnchantmentEffectsToAppliedEffects do
  use Ecto.Migration

  def up do
    # Effects can also come from potions and spells.
    rename table(:enchantment_effects), to: table(:applied_magic_effects)

    alter table(:applied_magic_effects) do
      add :potion_id, references(:objects, type: :string, on_delete: :delete_all), null: true
      modify :enchantment_id, references(:enchantments, type: :string, on_delete: :delete_all),
        null: true
    end

    # This will be recreated with the correct name in the modify line above
    drop constraint(:applied_magic_effects, :enchantment_effects_enchantment_id_fkey)

    execute "ALTER TABLE applied_magic_effects RENAME CONSTRAINT enchantment_effects_attribute_id_fkey TO applied_magic_effects_attribute_id_fkey;"
    execute "ALTER TABLE applied_magic_effects RENAME CONSTRAINT enchantment_effects_magic_effect_id_fkey TO applied_magic_effects_magic_effect_id_fkey;"
    execute "ALTER TABLE applied_magic_effects RENAME CONSTRAINT enchantment_effects_skill_id_fkey TO applied_magic_effects_skill_id_fkey;"

    execute "ALTER INDEX enchantment_effects_pkey RENAME TO applied_magic_effects_pkey;"
    execute "ALTER INDEX enchantment_effects_attribute_id_index RENAME TO applied_magic_effects_attribute_id_index;"
    execute "ALTER INDEX enchantment_effects_enchantment_id_index RENAME TO applied_magic_effects_enchantment_id_index;"
    execute "ALTER INDEX enchantment_effects_magic_effect_id_index RENAME TO applied_magic_effects_magic_effect_id_index;"
    execute "ALTER INDEX enchantment_effects_skill_id_index RENAME TO applied_magic_effects_skill_id_index;"
  end

  def down do
    rename table(:applied_magic_effects), to: table(:enchantment_effects)

    alter table(:enchantment_effects) do
      remove :potion_id
      modify :enchantment_id, references(:enchantments, type: :string), null: true
    end

    drop constraint(:enchantment_effects, :applied_magic_effects_enchantment_id_fkey)

    execute "ALTER TABLE enchantment_effects RENAME CONSTRAINT applied_magic_effects_attribute_id_fkey TO enchantment_effects_attribute_id_fkey;"
    execute "ALTER TABLE enchantment_effects RENAME CONSTRAINT applied_magic_effects_magic_effect_id_fkey TO enchantment_effects_magic_effect_id_fkey;"
    execute "ALTER TABLE enchantment_effects RENAME CONSTRAINT applied_magic_effects_skill_id_fkey TO enchantment_effects_skill_id_fkey;"

    execute "ALTER INDEX applied_magic_effects_pkey RENAME TO enchantment_effects_pkey;"
    execute "ALTER INDEX applied_magic_effects_attribute_id_index RENAME TO enchantment_effects_attribute_id_index;"
    execute "ALTER INDEX applied_magic_effects_enchantment_id_index RENAME TO enchantment_effects_enchantment_id_index;"
    execute "ALTER INDEX applied_magic_effects_magic_effect_id_index RENAME TO enchantment_effects_magic_effect_id_index;"
    execute "ALTER INDEX applied_magic_effects_skill_id_index RENAME TO enchantment_effects_skill_id_index;"
  end
end
