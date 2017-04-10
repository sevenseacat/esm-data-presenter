defmodule Codex.Repo.Migrations.SetUpObjectsAndBooks do
  use Ecto.Migration

  def up do
    create table(:objects, primary_key: false) do
      # General columns - all objects have these
      add :id, :string, primary_key: true
      add :name, :string, null: false
      add :value, :integer, default: 0
      add :weight, :decimal, null: false, precision: 5, scale: 2
      add :type, :string

      # Book-specific columns - some may be used by more than one type of object
      # but all of these will be used by books
      add :model, :string, null: false
      add :scroll, :boolean, null: false
      add :skill_id, references(:skills)
      add :enchantment_id, references(:enchantments, type: :string)
      add :enchantment_points, :integer, null: false, default: 0
      add :script_id, references(:scripts, type: :string)
      add :icon, :string
      add :text, :text
    end

    create unique_index(:objects, :id)
    create index(:objects, :skill_id)
    create index(:objects, :enchantment_id)
    create index(:objects, :script_id)
  end
end
