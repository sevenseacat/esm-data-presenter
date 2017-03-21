defmodule Codex.Repo.Migrations.CreateMagicEffects do
  use Ecto.Migration

  def change do
    create table(:magic_effects, primary_key: false) do
      add :id, :integer, null: false
      add :name, :string, null: false
      add :base_cost, :float, null: false
      add :color, :string, null: false
      add :description, :text
      add :icon, :string, null: false
      add :enchanting, :boolean, default: false
      add :spellmaking, :boolean, default: false
      add :negative, :boolean, default: false
      add :particle_texture, :string, null: false
      add :skill_id, references(:skills), null: false
      add :speed, :float, null: false, default: 1.0
      add :size, :float, null: false, default: 1.0
      add :size_cap, :float, null: false, default: 1.0

      add :area_sound, :string
      add :area_visual, :string
      add :bolt_sound, :string
      add :bolt_visual, :string
      add :cast_sound, :string
      add :cast_visual, :string
      add :hit_sound, :string
      add :hit_visual, :string
    end
  end
end
