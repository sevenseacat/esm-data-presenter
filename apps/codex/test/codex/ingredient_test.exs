defmodule Codex.IngredientTest do
  use Codex.ConnCase
  alias Codex.Ingredient
  doctest Codex.Ingredient

  test "has a valid factory" do
    assert insert(:ingredient)
  end

  describe "changeset/1" do
    test "validates that a valid ID is present" do
      ingredient = insert(:ingredient)

      assert {:id, "can't be blank"} in errors(Ingredient.changeset(%{}))
      assert {:error, changeset} = :ingredient |> params_for(id: ingredient.id) |>
        Ingredient.changeset |> Repo.insert
      assert {:id, "has already been taken"} in errors(changeset)
    end

    test "validates that a name is present" do
      assert {:name, "can't be blank"} in errors(Ingredient.changeset(%{}))
    end

    test "validates that a valid weight is provided" do
      assert {:weight, "can't be blank"} in errors(Ingredient.changeset(%{}))
      assert {:weight, "is invalid"} in errors(Ingredient.changeset(%{weight: "a"}))
      assert {:weight, "must be greater than or equal to 0"} in errors(Ingredient.changeset(%{weight: -1}))
    end

    test "validates that a model is present" do
      assert {:model, "can't be blank"} in errors(Ingredient.changeset(%{}))
    end

    test "validates that a valid value is provided" do
      assert {:value, "can't be blank"} in errors(Ingredient.changeset(%{}))
      assert {:value, "is invalid"} in errors(Ingredient.changeset(%{value: "a"}))
      assert {:value, "must be greater than or equal to 0"} in errors(Ingredient.changeset(%{value: -1}))
    end

    test "validates that an icon is present" do
      assert {:icon, "can't be blank"} in errors(Ingredient.changeset(%{}))
    end

    test "validates that any provided script ID is valid" do
      {:error, changeset} = :ingredient |> params_for |> Map.put(:script_id, "not valid")
        |> Ingredient.changeset |> Repo.insert
      assert {:script_id, "does not exist"} in errors(changeset)
    end
  end
end
