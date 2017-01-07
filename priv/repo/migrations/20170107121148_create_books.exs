defmodule Tes.Repo.Migrations.CreateBooks do
  use Ecto.Migration

  def change do
    create table(:books, primary_key: false) do
      add :id, :string, primary_key: true
      add :name, :string, null: false
      add :model, :string, null: false
      add :weight, :decimal, null: false, precision: 5, scale: 2
      add :value, :integer, null: false
      add :scroll, :boolean, null: false
      add :skill_id, references(:skills)
      add :enchantment_name, :string
      add :enchantment_points, :integer, null: false, default: 0
      add :script_name, :string
      add :texture, :string
      add :text, :text
    end

    create index(:books, :skill_id)
  end
end
