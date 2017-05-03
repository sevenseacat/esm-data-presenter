defmodule Codex.Repo.Migrations.AddArmorFieldsToObjects do
  use Ecto.Migration

  def change do
    rename table(:objects), :type, to: :object_type

    alter table(:objects) do
      # Stuff for all objects
      modify :object_type, :string, null: false
      modify :weight, :decimal, default: 0

      # Add new armor-specific fields
      add :type, :string
      add :armor_rating, :integer
      add :health, :integer

      # Make the book-specific fields nullable
      modify :scroll, :boolean, null: true
      modify :enchantment_points, :integer, null: true
    end
  end
end
