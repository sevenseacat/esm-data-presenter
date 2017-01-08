defmodule Tes.Repo.Migrations.CreateFactions do
  use Ecto.Migration

  def change do
    create table(:factions, primary_key: false) do
      add :id, :string, primary_key: true
      add :name, :string, null: false
      add :hidden, :boolean, default: false, null: false
      add :attribute_1_id, references(:attributes), null: false
      add :attribute_2_id, references(:attributes), null: false
    end

    create table(:faction_favorite_skills) do
      add :faction_id, references(:factions, type: :string, on_delete: :delete_all), null: false
      add :favorite_skill_id, references(:skills)
    end

    create index(:faction_favorite_skills, :faction_id)
    create index(:faction_favorite_skills, :favorite_skill_id)

    create table(:faction_ranks) do
      add :faction_id, references(:factions, type: :string, on_delete: :delete_all), null: false
      add :number, :integer, null: false
      add :name, :string, null: false
      add :attribute_1, :integer, null: false
      add :attribute_2, :integer, null: false
      add :skill_1, :integer, null: false
      add :skill_2, :integer
      add :reputation, :integer, null: false
    end

    create index(:faction_ranks, :faction_id)

    create table(:faction_reactions) do
      add :source_id, references(:factions, type: :string, on_delete: :delete_all), null: false
      add :target_id, :string, null: false
      add :adjustment, :integer, null: false
    end

    create index(:faction_reactions, :source_id)
    create index(:faction_reactions, :target_id)
  end
end
