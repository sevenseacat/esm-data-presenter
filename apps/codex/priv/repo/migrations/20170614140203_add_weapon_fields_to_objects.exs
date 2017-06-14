defmodule Codex.Repo.Migrations.AddWeaponFieldsToObjects do
  use Ecto.Migration

  def change do
    alter table(:objects) do
      add :chop_min, :integer
      add :chop_max, :integer
      add :slash_min, :integer
      add :slash_max, :integer
      add :thrust_min, :integer
      add :thrust_max, :integer
      add :reach, :decimal
      add :speed, :decimal

      add :ignore_resistance, :boolean
      add :silver, :boolean
    end
  end
end
