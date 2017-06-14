defmodule Codex.MiscItemTest do
  use Codex.ConnCase
  alias Codex.MiscItem
  doctest Codex.MiscItem

  test "has a valid factory" do
    assert insert(:misc_item)
  end

  describe "changeset/1" do
    test "validates that a valid ID is present" do
      misc_item = insert(:misc_item)

      assert {:id, "can't be blank"} in errors(MiscItem.changeset(%{}))
      assert {:error, changeset} = :misc_item |> params_for(id: misc_item.id) |> MiscItem.changeset
        |> Repo.insert
      assert {:id, "has already been taken"} in errors(changeset)
    end

    test "validates that a name is present" do
      assert {:name, "can't be blank"} in errors(MiscItem.changeset(%{}))
    end

    test "validates that a valid weight is present" do
      assert {:weight, "can't be blank"} in errors(MiscItem.changeset(%{}))
      assert {:weight, "is invalid"} in errors(MiscItem.changeset(%{weight: "a"}))
      assert {:weight, "must be greater than or equal to 0"} in errors(MiscItem.changeset(%{weight: -1}))
    end

    test "validates that a valid value is provided" do
      assert {:value, "can't be blank"} in errors(MiscItem.changeset(%{}))
      assert {:value, "is invalid"} in errors(MiscItem.changeset(%{value: "a"}))
      assert {:value, "must be greater than or equal to 0"} in errors(MiscItem.changeset(%{value: -1}))
    end

    test "validates that a model is present" do
      assert {:model, "can't be blank"} in errors(MiscItem.changeset(%{}))
    end

    test "validates that an icon is present" do
      assert {:icon, "can't be blank"} in errors(MiscItem.changeset(%{}))
    end

    test "validates that any provided enchantment ID is valid" do
      {:error, changeset} = :misc_item |> params_for |> Map.put(:enchantment_id, "not valid")
        |> MiscItem.changeset |> Repo.insert
      assert {:enchantment_id, "does not exist"} in errors(changeset)
    end

    test "validates that any provided script ID is valid" do
      {:error, changeset} = :misc_item |> params_for |> Map.put(:script_id, "not valid")
        |> MiscItem.changeset |> Repo.insert
      assert {:script_id, "does not exist"} in errors(changeset)
    end
  end
end
