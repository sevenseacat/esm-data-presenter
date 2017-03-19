defmodule Codex.Repo.Migrations.CreateSpecializations do
  use Ecto.Migration

  def change do
    create table(:specializations) do
      add :name, :string, null: false
    end
  end
end
