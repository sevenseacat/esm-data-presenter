defmodule Codex.Repo.Migrations.AddWeightClassToObjects do
  use Ecto.Migration

  def change do
    alter table(:objects) do
      add :weight_class, :string
    end
  end
end
