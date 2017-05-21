defmodule Codex.IngredientEffectTest do
  use Codex.ConnCase
  alias Codex.Ingredient.Effect
  doctest Codex.Ingredient.Effect

  test "has a valid factory" do
    assert insert(:ingredient_effect)
  end

  describe "changeset/1" do
    test "validates that an attribute ID is not required" do
      refute {:attribute_id, "can't be blank"} in errors(Effect.changeset(%{}))
    end

    test "validates that a provided attribute ID is valid" do
      params = :ingredient_effect |> params_with_assocs |> Map.put(:attribute_id, -1)
      {:error, changeset} = params |> Effect.changeset |> Repo.insert
      assert {:attribute_id, "does not exist"} in errors(changeset)
    end

    test "validates that a magic effect ID is provided" do
      assert {:magic_effect_id, "can't be blank"} in errors(Effect.changeset(%{}))
    end

    test "validates that a provided magic effect ID is valid" do
      params = :ingredient_effect |> params_with_assocs |> Map.put(:magic_effect_id, -1)
      {:error, changeset} = params |> Effect.changeset |> Repo.insert
      assert {:magic_effect_id, "does not exist"} in errors(changeset)
    end

    test "validates that a skill ID is not required" do
      refute {:skill_id, "can't be blank"} in errors(Effect.changeset(%{}))
    end

    test "validates that a provided skill ID is valid" do
      params = :ingredient_effect |> params_with_assocs |> Map.put(:skill_id, -1)
      {:error, changeset} = params |> Effect.changeset |> Repo.insert
      assert {:skill_id, "does not exist"} in errors(changeset)
    end

    test "validates that only one of a skill or attribute is provided" do
      changeset = :ingredient_effect |> params_with_assocs |> Map.put(:skill_id, 1)
        |> Map.put(:attribute_id, 2) |> Effect.changeset
      assert {:skill_id, "must be nil if an attribute ID is also provided"} in errors(changeset)
    end
  end
end
