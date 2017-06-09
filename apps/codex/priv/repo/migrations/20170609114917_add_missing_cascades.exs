defmodule Codex.Repo.Migrations.AddMissingCascades do
  use Ecto.Migration

  def change do
    execute "ALTER TABLE enchantment_effects
      DROP CONSTRAINT enchantment_effects_skill_id_fkey,
      ADD CONSTRAINT enchantment_effects_skill_id_fkey FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE CASCADE"

    execute "ALTER TABLE magic_effects
      DROP CONSTRAINT magic_effects_skill_id_fkey,
      ADD CONSTRAINT magic_effects_skill_id_fkey FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE CASCADE"

    execute "ALTER TABLE enchantment_effects
      DROP CONSTRAINT enchantment_effects_magic_effect_id_fkey,
      ADD CONSTRAINT enchantment_effects_magic_effect_id_fkey FOREIGN KEY (magic_effect_id) REFERENCES magic_effects(id) ON DELETE CASCADE"

    execute "ALTER TABLE ingredient_effects
      DROP CONSTRAINT ingredient_effects_magic_effect_id_fkey,
      ADD CONSTRAINT ingredient_effects_magic_effect_id_fkey FOREIGN KEY (magic_effect_id) REFERENCES magic_effects(id) ON DELETE CASCADE"

    execute "ALTER TABLE objects
      DROP CONSTRAINT objects_script_id_fkey,
      ADD CONSTRAINT objects_script_id_fkey FOREIGN KEY (script_id) REFERENCES scripts(id) ON DELETE CASCADE"

    execute "ALTER TABLE objects
      DROP CONSTRAINT objects_skill_id_fkey,
      ADD CONSTRAINT objects_skill_id_fkey FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE CASCADE"

    execute "ALTER TABLE objects
      DROP CONSTRAINT objects_enchantment_id_fkey,
      ADD CONSTRAINT objects_enchantment_id_fkey FOREIGN KEY (enchantment_id) REFERENCES enchantments(id) ON DELETE CASCADE"
  end
end
