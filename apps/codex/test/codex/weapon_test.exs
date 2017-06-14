defmodule Codex.WeaponTest do
  use Codex.ConnCase
  alias Codex.Weapon
  doctest Codex.Weapon

  test "has a valid factory" do
    assert insert(:weapon)
  end

  describe "changeset/1" do
    test "validates that a valid ID is present" do
      weapon = insert(:weapon)

      assert {:id, "can't be blank"} in errors(Weapon.changeset(%{}))
      assert {:error, changeset} = :weapon |> params_for(id: weapon.id) |> Weapon.changeset
        |> Repo.insert
      assert {:id, "has already been taken"} in errors(changeset)
    end

    test "validates that a name is present" do
      assert {:name, "can't be blank"} in errors(Weapon.changeset(%{}))
    end

    test "validates that a valid type is present" do
      assert {:type, "can't be blank"} in errors(Weapon.changeset(%{}))
      assert {:type, "is invalid"} in errors(Weapon.changeset(%{type: "not_valid"}))
      refute {:type, "is invalid"} in errors(Weapon.changeset(%{type: "blunt_1_hand"}))
    end

    test "validates that a valid weight is present" do
      assert {:weight, "can't be blank"} in errors(Weapon.changeset(%{}))
      assert {:weight, "is invalid"} in errors(Weapon.changeset(%{weight: "a"}))
      assert {:weight, "must be greater than or equal to 0"} in errors(Weapon.changeset(%{weight: -1}))
    end

    test "validates that a valid value is provided" do
      assert {:value, "can't be blank"} in errors(Weapon.changeset(%{}))
      assert {:value, "is invalid"} in errors(Weapon.changeset(%{value: "a"}))
      assert {:value, "must be greater than or equal to 0"} in errors(Weapon.changeset(%{value: -1}))
    end

    test "validates that a model is present" do
      assert {:model, "can't be blank"} in errors(Weapon.changeset(%{}))
    end

    test "validates that valid chop values are present" do
      assert {:chop_min, "can't be blank"} in errors(Weapon.changeset(%{}))
      assert {:chop_min, "is invalid"} in errors(Weapon.changeset(%{chop_min: "a"}))
      assert {:chop_min, "must be greater than or equal to 0"} in errors(Weapon.changeset(%{chop_min: -1}))

      assert {:chop_max, "can't be blank"} in errors(Weapon.changeset(%{}))
      assert {:chop_max, "is invalid"} in errors(Weapon.changeset(%{chop_max: "a"}))
      assert {:chop_max, "must be greater than or equal to 0"} in errors(Weapon.changeset(%{chop_max: -1}))
    end

    test "validates that valid slash values are present" do
      assert {:slash_min, "can't be blank"} in errors(Weapon.changeset(%{}))
      assert {:slash_min, "is invalid"} in errors(Weapon.changeset(%{slash_min: "a"}))
      assert {:slash_min, "must be greater than or equal to 0"} in errors(Weapon.changeset(%{slash_min: -1}))

      assert {:slash_max, "can't be blank"} in errors(Weapon.changeset(%{}))
      assert {:slash_max, "is invalid"} in errors(Weapon.changeset(%{slash_max: "a"}))
      assert {:slash_max, "must be greater than or equal to 0"} in errors(Weapon.changeset(%{slash_max: -1}))
    end

    test "validates that valid thrust values are present" do
      assert {:thrust_min, "can't be blank"} in errors(Weapon.changeset(%{}))
      assert {:thrust_min, "is invalid"} in errors(Weapon.changeset(%{thrust_min: "a"}))
      assert {:thrust_min, "must be greater than or equal to 0"} in errors(Weapon.changeset(%{thrust_min: -1}))

      assert {:thrust_max, "can't be blank"} in errors(Weapon.changeset(%{}))
      assert {:thrust_max, "is invalid"} in errors(Weapon.changeset(%{thrust_max: "a"}))
      assert {:thrust_max, "must be greater than or equal to 0"} in errors(Weapon.changeset(%{thrust_max: -1}))
    end

    test "validates that a valid health is present" do
      assert {:health, "can't be blank"} in errors(Weapon.changeset(%{}))
      assert {:health, "is invalid"} in errors(Weapon.changeset(%{health: "a"}))
      assert {:health, "must be greater than or equal to 0"} in errors(Weapon.changeset(%{health: -1}))
    end

    test "validates that a valid enchantment point value is provided" do
      assert {:enchantment_points, "can't be blank"} in errors(Weapon.changeset(%{}))
      assert {:enchantment_points, "is invalid"} in
        errors(Weapon.changeset(%{enchantment_points: "a"}))
      assert {:enchantment_points, "must be greater than or equal to 0"} in
        errors(Weapon.changeset(%{enchantment_points: -1}))
    end

    test "validates that a valid reach is provided" do
      assert {:reach, "can't be blank"} in errors(Weapon.changeset(%{}))
      assert {:reach, "is invalid"} in errors(Weapon.changeset(%{reach: "a"}))
      assert {:reach, "must be greater than or equal to 0"} in errors(Weapon.changeset(%{reach: -1}))
    end

    test "validates that a valid speed is provided" do
      assert {:speed, "can't be blank"} in errors(Weapon.changeset(%{}))
      assert {:speed, "is invalid"} in errors(Weapon.changeset(%{speed: "a"}))
      assert {:speed, "must be greater than or equal to 0"} in errors(Weapon.changeset(%{speed: -1}))
    end

    test "validates that any provided enchantment ID is valid" do
      {:error, changeset} = :weapon |> params_for |> Map.put(:enchantment_id, "not valid")
        |> Weapon.changeset |> Repo.insert
      assert {:enchantment_id, "does not exist"} in errors(changeset)
    end

    test "validates that any provided script ID is valid" do
      {:error, changeset} = :weapon |> params_for |> Map.put(:script_id, "not valid")
        |> Weapon.changeset |> Repo.insert
      assert {:script_id, "does not exist"} in errors(changeset)
    end

    test "ensures that ignore_resistance and silver values are cast correctly" do
      assert %{silver: false, ignore_resistance: false} =
        (%{silver: false, ignore_resistance: false} |> Weapon.changeset |> Map.get(:changes))

      assert %{silver: true, ignore_resistance: true} =
        (%{silver: true, ignore_resistance: true} |> Weapon.changeset |> Map.get(:changes))
    end
  end
end
