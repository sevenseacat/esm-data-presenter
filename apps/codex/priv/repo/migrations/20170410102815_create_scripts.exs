defmodule Codex.Repo.Migrations.CreateScripts do
  use Ecto.Migration

  def change do
    create table(:scripts, primary_key: false) do
      add :id, :string, primary_key: true
      add :text, :text, null: false
    end
  end
end
