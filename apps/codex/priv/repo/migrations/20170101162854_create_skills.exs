defmodule Codex.Repo.Migrations.CreateSkills do
  use Ecto.Migration

  def change do
    create table(:skills) do
      add :name, :string, null: false
      add :description, :text, null: false

      add :attribute_id, references(:attributes)
      add :specialization_id, references(:specializations)
    end

    create index(:skills, :attribute_id)
    create index(:skills, :specialization_id)
  end
end
