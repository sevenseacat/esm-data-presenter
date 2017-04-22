defmodule Codex.FactionTest do
  use Codex.ConnCase
  alias Codex.{Faction, Repo}
  doctest Codex.Faction

  test "has a valid factory" do
    assert insert(:faction)
  end

  describe "changeset/1" do
    test "validates that an ID is provided" do
      assert {:id, "can't be blank"} in errors(Faction.changeset(%{}))
    end

    test "validates that a name is provided" do
      assert {:name, "can't be blank"} in errors(Faction.changeset(%{}))
    end

    test "validates that two attribute IDs are provided" do
      assert {:attribute_1_id, "can't be blank"} in errors(Faction.changeset(%{}))
      assert {:attribute_2_id, "can't be blank"} in errors(Faction.changeset(%{}))
    end

    test "validates that the first attribute ID provided is valid" do
      params = params_with_assocs(:faction)
      {:error, changeset} = params |> Map.put(:attribute_1_id, -1) |> Faction.changeset
        |> Repo.insert
      assert {:attribute_1_id, "does not exist"} in errors(changeset)
    end

    test "validates that the second attribute ID provided is valid" do
      params = params_with_assocs(:faction)
      {:error, changeset} = params |> Map.put(:attribute_2_id, -1) |> Faction.changeset
        |> Repo.insert
      assert {:attribute_2_id, "does not exist"} in errors(changeset)
    end

    test "casts faction reactions correctly" do
      changeset = Faction.changeset(%{reactions: [%{}, %{}]})

      assert length(changeset.changes[:reactions]) == 2
      Enum.each(changeset.changes[:reactions], fn reaction ->
        assert match?(%Ecto.Changeset{data: %Codex.Faction.Reaction{}}, reaction)
      end)
    end

    test "casts faction ranks correctly" do
      changeset = Faction.changeset(%{ranks: [%{}]})

      assert length(changeset.changes[:ranks]) == 1
      assert Enum.all?(changeset.changes[:ranks], &(match?(%Ecto.Changeset{}, &1)))
    end
  end
end
