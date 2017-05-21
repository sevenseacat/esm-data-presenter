defmodule Codex.Repo.Migrations.CreateIngredientEffects do
  use Ecto.Migration

  def change do
    create table(:ingredient_effects) do
      add :ingredient_id, references(:objects, type: :string)
      add :attribute_id, references(:attributes)
      add :magic_effect_id, references(:magic_effects)
      add :skill_id, references(:skills)
    end
  end
end
