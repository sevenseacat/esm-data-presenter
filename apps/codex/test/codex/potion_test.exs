defmodule Codex.PotionTest do
  use Codex.ConnCase
  alias Codex.Potion
  doctest Codex.Potion

  test "has a valid factory" do
    assert insert(:potion)
  end

  describe "changeset/1" do
    test "validates that a valid ID is present" do
      potion = insert(:potion)

      assert {:id, "can't be blank"} in errors(Potion.changeset(%{}))
      assert {:error, changeset} = :potion |> params_for(id: potion.id) |> Potion.changeset
        |> Repo.insert
      assert {:id, "has already been taken"} in errors(changeset)
    end

    test "validates that a name is present" do
      assert {:name, "can't be blank"} in errors(Potion.changeset(%{}))
    end

    test "validates that a valid weight is present" do
      assert {:weight, "can't be blank"} in errors(Potion.changeset(%{}))
      assert {:weight, "is invalid"} in errors(Potion.changeset(%{weight: "a"}))
      assert {:weight, "must be greater than or equal to 0"} in errors(Potion.changeset(%{weight: -1}))
    end

    test "validates that a valid value is provided" do
      assert {:value, "can't be blank"} in errors(Potion.changeset(%{}))
      assert {:value, "is invalid"} in errors(Potion.changeset(%{value: "a"}))
      assert {:value, "must be greater than or equal to 0"} in errors(Potion.changeset(%{value: -1}))
    end

    test "validates that a model is present" do
      assert {:model, "can't be blank"} in errors(Potion.changeset(%{}))
    end

    test "validates that an icon is present" do
      assert {:icon, "can't be blank"} in errors(Potion.changeset(%{}))
    end

    test "casts enchantment effects correctly" do
      changeset = Potion.changeset(%{effects: [%{}]})

      assert length(changeset.changes[:effects]) == 1
      assert Enum.all?(changeset.changes[:effects], &(match?(%Ecto.Changeset{}, &1)))
    end
  end
end
