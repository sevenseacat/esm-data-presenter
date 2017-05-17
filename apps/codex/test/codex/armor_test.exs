defmodule Codex.ArmorTest do
  use Codex.ConnCase
  alias Codex.Armor
  doctest Codex.Armor

  test "has a valid factory" do
    assert insert(:armor)
  end

  describe "weight_class/1" do
    test "works correctly for boots" do
      assert Armor.weight_class(%{type: "boots", weight: 5.0}) == "light"
      assert Armor.weight_class(%{type: "boots", weight: 10.0}) == "light"
      assert Armor.weight_class(%{type: "boots", weight: 12.0}) == "light"
      assert Armor.weight_class(%{type: "boots", weight: 13.0}) == "medium"
      assert Armor.weight_class(%{type: "boots", weight: 15.0}) == "medium"
      assert Armor.weight_class(%{type: "boots", weight: 17.0}) == "medium"
      assert Armor.weight_class(%{type: "boots", weight: 18.0}) == "medium"
      assert Armor.weight_class(%{type: "boots", weight: 20.0}) == "heavy"
      assert Armor.weight_class(%{type: "boots", weight: 25.0}) == "heavy"
    end

    test "works correctly for cuirasses" do
      assert Armor.weight_class(%{type: "cuirass", weight: 10.0}) == "light"
      assert Armor.weight_class(%{type: "cuirass", weight: 15.0}) == "light"
      assert Armor.weight_class(%{type: "cuirass", weight: 17.5}) == "light"
      assert Armor.weight_class(%{type: "cuirass", weight: 18.0}) == "light"
      assert Armor.weight_class(%{type: "cuirass", weight: 18.5}) == "medium"
      assert Armor.weight_class(%{type: "cuirass", weight: 25.0}) == "medium"
      assert Armor.weight_class(%{type: "cuirass", weight: 27.0}) == "medium"
      assert Armor.weight_class(%{type: "cuirass", weight: 27.5}) == "heavy"
      assert Armor.weight_class(%{type: "cuirass", weight: 30.0}) == "heavy"
    end

    test "works correctly for greaves and shields" do
      ["greaves", "shield"]
      |> Enum.each(fn type ->
        assert Armor.weight_class(%{type: type, weight: 5.0}) == "light"
        assert Armor.weight_class(%{type: type, weight: 8.5}) == "light"
        assert Armor.weight_class(%{type: type, weight: 9.0}) == "light"
        assert Armor.weight_class(%{type: type, weight: 9.5}) == "medium"
        assert Armor.weight_class(%{type: type, weight: 10.0}) == "medium"
        assert Armor.weight_class(%{type: type, weight: 13.0}) == "medium"
        assert Armor.weight_class(%{type: type, weight: 13.5}) == "medium"
        assert Armor.weight_class(%{type: type, weight: 14.0}) == "heavy"
      end)
    end

    test "works correctly for bracers, gauntlets, and helmets" do
      ["left_bracer", "right_bracer", "left_gauntlet", "right_gauntlet", "helmet"]
      |> Enum.each(fn type ->
        assert Armor.weight_class(%{type: type, weight: 2.0}) == "light"
        assert Armor.weight_class(%{type: type, weight: 2.5}) == "light"
        assert Armor.weight_class(%{type: type, weight: 3.0}) == "light"
        assert Armor.weight_class(%{type: type, weight: 3.5}) == "medium"
        assert Armor.weight_class(%{type: type, weight: 4.0}) == "medium"
        assert Armor.weight_class(%{type: type, weight: 4.5}) == "medium"
        assert Armor.weight_class(%{type: type, weight: 5.0}) == "heavy"
      end)
    end

    test "works correctly for pauldrons" do
      ["left_pauldron", "right_pauldron"]
      |> Enum.each(fn type ->
        assert Armor.weight_class(%{type: type, weight: 5.0}) == "light"
        assert Armor.weight_class(%{type: type, weight: 6.0}) == "light"
        assert Armor.weight_class(%{type: type, weight: 7.0}) == "medium"
        assert Armor.weight_class(%{type: type, weight: 8.0}) == "medium"
        assert Armor.weight_class(%{type: type, weight: 9.0}) == "medium"
        assert Armor.weight_class(%{type: type, weight: 10.0}) == "heavy"
      end)
    end

    test "raises an error when given an unknown armor type" do
      assert_raise RuntimeError, "unknown armor type 'dress'", fn ->
        Armor.weight_class(%{type: "dress", weight: 5.0})
      end
    end
  end

  describe "changeset/1" do
    test "validates that a valid ID is present" do
      armor = insert(:armor)

      assert {:id, "can't be blank"} in errors(Armor.changeset(%{}))
      assert {:error, changeset} = :armor |> params_for(id: armor.id) |> Armor.changeset
        |> Repo.insert
      assert {:id, "has already been taken"} in errors(changeset)
    end

    test "validates that a name is present" do
      assert {:name, "can't be blank"} in errors(Armor.changeset(%{}))
    end

    test "validates that a valid type is present" do
      assert {:type, "can't be blank"} in errors(Armor.changeset(%{}))
      assert {:type, "is invalid"} in errors(Armor.changeset(%{type: "not_valid"}))
      refute Keyword.has_key?(errors(Armor.changeset(%{type: "helmet"})), :type)
    end

    test "validates that a valid weight is present" do
      assert {:weight, "can't be blank"} in errors(Armor.changeset(%{}))
      assert {:weight, "is invalid"} in errors(Armor.changeset(%{weight: "a"}))
      assert {:weight, "must be greater than or equal to 0"} in errors(Armor.changeset(%{weight: -1}))
    end

    test "validates that a valid armor rating is present" do
      assert {:armor_rating, "can't be blank"} in errors(Armor.changeset(%{}))
      assert {:armor_rating, "is invalid"} in errors(Armor.changeset(%{armor_rating: "a"}))
      assert {:armor_rating, "must be greater than or equal to 0"} in errors(Armor.changeset(%{armor_rating: -1}))
    end

    test "validates that a valid health is present" do
      assert {:health, "can't be blank"} in errors(Armor.changeset(%{}))
      assert {:health, "is invalid"} in errors(Armor.changeset(%{health: "a"}))
      assert {:health, "must be greater than or equal to 0"} in errors(Armor.changeset(%{health: -1}))
    end

    test "validates that a valid value is provided" do
      assert {:value, "can't be blank"} in errors(Armor.changeset(%{}))
      assert {:value, "is invalid"} in errors(Armor.changeset(%{value: "a"}))
      assert {:value, "must be greater than or equal to 0"} in errors(Armor.changeset(%{value: -1}))
    end

    test "validates that a valid enchantment point value is provided" do
      assert {:enchantment_points, "can't be blank"} in errors(Armor.changeset(%{}))
      assert {:enchantment_points, "is invalid"} in
        errors(Armor.changeset(%{enchantment_points: "a"}))
      assert {:enchantment_points, "must be greater than or equal to 0"} in
        errors(Armor.changeset(%{enchantment_points: -1}))
    end

    test "validates that any provided enchantment ID is valid" do
      {:error, changeset} = :armor |> params_for |> Map.put(:enchantment_id, "not valid") |> Armor.changeset
        |> Repo.insert
      assert {:enchantment_id, "does not exist"} in errors(changeset)
    end

    test "validates that any provided script ID is valid" do
      {:error, changeset} = :armor |> params_for |> Map.put(:script_id, "not valid") |> Armor.changeset
        |> Repo.insert
      assert {:script_id, "does not exist"} in errors(changeset)
    end

    test "validates that a model is present" do
      assert {:model, "can't be blank"} in errors(Armor.changeset(%{}))
    end

    test "validates that an icon is present" do
      assert {:icon, "can't be blank"} in errors(Armor.changeset(%{}))
    end

    test "calculates and stores the correct weight class" do
      changeset = Armor.changeset(%{type: "right_pauldron", weight: 7})
      assert changeset.changes[:weight_class] == "medium"
    end
  end
end
