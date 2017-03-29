defmodule Codex.Repo.Migrations.CreateEnchantments do
  use Ecto.Migration

  def change do
    create table(:enchantments, primary_key: false) do
      add :id, :string, primary_key: true
      add :type, :string, null: false
      add :charge, :integer, default: 0
      add :cost, :integer, default: 0
      add :autocalc, :boolean, default: true
    end

    create table(:enchantment_effects) do
      add :area, :integer
      add :duration, :integer
      add :magnitude_min, :integer
      add :magnitude_max, :integer
      add :type, :string

      add :enchantment_id, references(:enchantments, type: :string, on_delete: :delete_all),
        null: false
      add :attribute_id, references(:attributes)
      add :magic_effect_id, references(:magic_effects)
      add :skill_id, references(:skills)
    end
  end
end
