defmodule Codex.Repo.Migrations.AddToolFieldsToObjects do
  use Ecto.Migration

  def change do
    alter table(:objects) do
      add :quality, :decimal
      add :uses, :integer
    end
  end
end
