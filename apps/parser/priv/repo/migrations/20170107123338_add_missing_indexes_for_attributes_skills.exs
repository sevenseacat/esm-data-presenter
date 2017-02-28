defmodule Tes.Repo.Migrations.AddMissingIndexesForAttributesSkills do
  use Ecto.Migration

  def change do
    alter table(:specializations) do
      modify :name, :string, null: false
    end

    alter table(:attributes) do
      modify :name, :string, null: false
    end

    alter table(:skills) do
      modify :name, :string, null: false
      modify :description, :text, null: false
    end

    create index(:skills, :attribute_id)
    create index(:skills, :specialization_id)
  end
end
