defmodule Codex.SpellTest do
  use Codex.ConnCase
  alias Codex.Spell
  doctest Codex.Spell

  test "has a valid factory" do
    assert insert(:spell)
  end

  describe "changeset/1" do
    test "validates that a valid ID is present" do
      spell = insert(:spell)

      assert {:id, "can't be blank"} in errors(Spell.changeset(%{}))
      assert {:error, changeset} = :spell |> params_for(id: spell.id) |> Spell.changeset
        |> Repo.insert
      assert {:id, "has already been taken"} in errors(changeset)
    end

    test "validates that a name is present" do
      assert {:name, "can't be blank"} in errors(Spell.changeset(%{}))
    end

    test "validates that a valid cost is provided" do
      assert {:cost, "can't be blank"} in errors(Spell.changeset(%{}))
      assert {:cost, "is invalid"} in errors(Spell.changeset(%{cost: "a"}))
      assert {:cost, "must be greater than or equal to 0"} in errors(Spell.changeset(%{cost: -1}))
    end

    test "validates that a valid type is present" do
      assert {:type, "can't be blank"} in errors(Spell.changeset(%{}))
      assert {:type, "is invalid"} in errors(Spell.changeset(%{type: "not_valid"}))
      refute {:type, "is invalid"} in errors(Spell.changeset(%{type: "power"}))
    end

    test "casts enchantment effects correctly" do
      changeset = Spell.changeset(%{effects: [%{}]})

      assert length(changeset.changes[:effects]) == 1
      assert Enum.all?(changeset.changes[:effects], &(match?(%Ecto.Changeset{}, &1)))
    end
  end
end
