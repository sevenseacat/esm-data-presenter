defmodule Codex.Repo.Migrations.CreateClasses do
  use Ecto.Migration

  def change do
    create table(:classes, primary_key: false) do
      add :id, :string, primary_key: true
      add :name, :string
      add :description, :string
      add :specialization_id, references(:specializations)
      add :attribute_1_id, references(:attributes)
      add :attribute_2_id, references(:attributes)
      add :playable, :boolean, null: false
      add :services, {:map, :boolean}, null: false
      add :vendors, {:map, :boolean}, null: false
    end

    create index(:classes, :attribute_1_id)
    create index(:classes, :attribute_2_id)

    create table(:class_skills, primary_key: false) do
      add :class_id, references(:classes, type: :string, on_delete: :delete_all)
      add :skill_id, references(:skills, on_delete: :delete_all)
    end

    create table(:minor_class_skills, primary_key: false, options: "inherits (class_skills)")
    create table(:major_class_skills, primary_key: false, options: "inherits (class_skills)")
  end
end
