defmodule Tes.Repo.Migrations.CreateSkills do
  use Ecto.Migration

  def change do
    create table(:skills) do
      add :name, :string
      add :description, :text

      add :attribute_id, references(:attributes)
      add :specialization_id, references(:specializations)
    end
  end
end
