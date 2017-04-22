defmodule Codex.EnchantmentTest do
  use Codex.ConnCase
  alias Codex.Enchantment
  doctest Codex.Enchantment

  test "has a valid factory" do
    assert insert(:enchantment)
  end

  describe "changeset/1" do
    test "validates that an ID is provided" do
      assert {:id, "can't be blank"} in errors(Enchantment.changeset(%{}))
    end

    test "validates that a valid type is provided" do
      assert {:type, "can't be blank"} in errors(Enchantment.changeset(%{}))
      assert {:type, "is invalid"} in errors(Enchantment.changeset(%{type: "not_valid"}))
      refute Keyword.has_key?(errors(Enchantment.changeset(%{type: "when_used"})), :type)
    end

    test "validates that a valid cost is provided" do
      assert {:cost, "can't be blank"} in errors(Enchantment.changeset(%{}))
      assert {:cost, "is invalid"} in errors(Enchantment.changeset(%{cost: "a"}))
      assert {:cost, "must be greater than or equal to 0"} in errors(Enchantment.changeset(%{cost: -1}))
    end

    test "validates that a valid charge is provided" do
      assert {:charge, "can't be blank"} in errors(Enchantment.changeset(%{}))
      assert {:charge, "is invalid"} in errors(Enchantment.changeset(%{charge: "a"}))
      assert {:charge, "must be greater than or equal to 0"} in errors(Enchantment.changeset(%{charge: -1}))
    end

    test "casts enchantment effects correctly" do
      changeset = Enchantment.changeset(%{enchantment_effects: [%{}]})

      assert length(changeset.changes[:enchantment_effects]) == 1
      assert Enum.all?(changeset.changes[:enchantment_effects], &(match?(%Ecto.Changeset{}, &1)))
    end
  end
end
