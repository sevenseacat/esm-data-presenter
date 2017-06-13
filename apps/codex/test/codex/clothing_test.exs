defmodule Codex.ClothingTest do
  use Codex.ConnCase
  alias Codex.Clothing
  doctest Codex.Clothing

  test "has a valid factory" do
    assert insert(:clothing)
  end

  describe "changeset/1" do
    test "validates that a valid ID is present" do
      clothing = insert(:clothing)

      assert {:id, "can't be blank"} in errors(Clothing.changeset(%{}))
      assert {:error, changeset} = :clothing |> params_for(id: clothing.id) |> Clothing.changeset
        |> Repo.insert
      assert {:id, "has already been taken"} in errors(changeset)
    end

    test "validates that a name is present" do
      assert {:name, "can't be blank"} in errors(Clothing.changeset(%{}))
    end

    test "validates that a valid type is present" do
      assert {:type, "can't be blank"} in errors(Clothing.changeset(%{}))
      assert {:type, "is invalid"} in errors(Clothing.changeset(%{type: "not_valid"}))
      refute {:type, "is invalid"} in errors(Clothing.changeset(%{type: "robe"}))
    end

    test "validates that a valid weight is present" do
      assert {:weight, "can't be blank"} in errors(Clothing.changeset(%{}))
      assert {:weight, "is invalid"} in errors(Clothing.changeset(%{weight: "a"}))
      assert {:weight, "must be greater than or equal to 0"} in errors(Clothing.changeset(%{weight: -1}))
    end

    test "validates that a valid value is provided" do
      assert {:value, "can't be blank"} in errors(Clothing.changeset(%{}))
      assert {:value, "is invalid"} in errors(Clothing.changeset(%{value: "a"}))
      assert {:value, "must be greater than or equal to 0"} in errors(Clothing.changeset(%{value: -1}))
    end

    test "validates that a valid enchantment point value is provided" do
      assert {:enchantment_points, "can't be blank"} in errors(Clothing.changeset(%{}))
      assert {:enchantment_points, "is invalid"} in
        errors(Clothing.changeset(%{enchantment_points: "a"}))
      assert {:enchantment_points, "must be greater than or equal to 0"} in
        errors(Clothing.changeset(%{enchantment_points: -1}))
    end

    test "validates that any provided enchantment ID is valid" do
      {:error, changeset} = :clothing |> params_for |> Map.put(:enchantment_id, "not valid")
        |> Clothing.changeset |> Repo.insert
      assert {:enchantment_id, "does not exist"} in errors(changeset)
    end

    test "validates that any provided script ID is valid" do
      {:error, changeset} = :clothing |> params_for |> Map.put(:script_id, "not valid")
        |> Clothing.changeset |> Repo.insert
      assert {:script_id, "does not exist"} in errors(changeset)
    end

    test "validates that a model is present" do
      assert {:model, "can't be blank"} in errors(Clothing.changeset(%{}))
    end
  end
end
