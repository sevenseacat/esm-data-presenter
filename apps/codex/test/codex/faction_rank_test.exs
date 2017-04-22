defmodule Codex.Faction.RankTest do
  use Codex.ConnCase
  alias Codex.{Faction.Rank, Repo}
  doctest Codex.Faction.Rank

  test "has a valid factory" do
    assert insert(:faction_rank)
  end

  describe "changeset/2" do
    test "validates that the faction is valid" do
      assert {:faction_id, "can't be blank"} in errors(Rank.changeset(%{}))

      params = :faction_rank |> params_with_assocs |> Map.put(:faction_id, "not valid")
      {:error, changeset} = params |> Rank.changeset |> Repo.insert
      assert {:faction, "does not exist"} in errors(changeset)
    end

    test "validates that a valid rank number is provided" do
      assert {:number, "can't be blank"} in errors(Rank.changeset(%{}))
      assert {:number, "must be greater than 0"} in errors(Rank.changeset(%{number: 0}))
      assert {:number, "is invalid"} in errors(Rank.changeset(%{number: "a"}))
    end

    test "validates that a name is provided" do
      assert {:name, "can't be blank"} in errors(Rank.changeset(%{}))
    end

    test "validates that valid attribute values are provided" do
      assert {:attribute_1, "can't be blank"} in errors(Rank.changeset(%{}))
      assert {:attribute_1, "must be greater than or equal to 0"} in errors(Rank.changeset(%{attribute_1: -1}))
      assert {:attribute_1, "is invalid"} in errors(Rank.changeset(%{attribute_1: "a"}))

      assert {:attribute_2, "can't be blank"} in errors(Rank.changeset(%{}))
      assert {:attribute_2, "must be greater than or equal to 0"} in errors(Rank.changeset(%{attribute_2: -1}))
      assert {:attribute_2, "is invalid"} in errors(Rank.changeset(%{attribute_2: "a"}))
    end

    test "validates that valid skill values are provided" do
      assert {:skill_1, "can't be blank"} in errors(Rank.changeset(%{}))
      assert {:skill_1, "must be greater than or equal to 0"} in errors(Rank.changeset(%{skill_1: -1}))
      assert {:skill_1, "is invalid"} in errors(Rank.changeset(%{skill_1: "a"}))

      assert {:skill_2, "can't be blank"} in errors(Rank.changeset(%{}))
      assert {:skill_2, "must be greater than or equal to 0"} in errors(Rank.changeset(%{skill_2: -1}))
      assert {:skill_2, "is invalid"} in errors(Rank.changeset(%{skill_2: "a"}))
    end

    test "validates that a valid faction reputation is provided" do
      assert {:reputation, "can't be blank"} in errors(Rank.changeset(%{}))
      assert {:reputation, "must be greater than or equal to 0"} in errors(Rank.changeset(%{reputation: -1}))
      assert {:reputation, "is invalid"} in errors(Rank.changeset(%{reputation: "a"}))
    end
  end
end
