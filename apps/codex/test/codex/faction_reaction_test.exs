defmodule Codex.Faction.ReactionTest do
  use Codex.ConnCase
  alias Codex.Faction.Reaction
  doctest Codex.Faction.Reaction

  test "has a valid factory" do
    assert insert(:faction_reaction)
  end

  describe "changeset/2" do
    test "validates that the source faction is valid" do
      params = :faction_reaction |> params_with_assocs |> Map.put(:source_id, "no")
      # ex_machina provides the keys in a slightly different format than the parser provides
      fixed_params = params |> Map.put(:faction_id, params[:target_id])
      {:error, changeset} = fixed_params |> Reaction.changeset |> Repo.insert
      assert {:source, "does not exist"} in errors(changeset)
    end

    test "validates that a target faction ID is provided" do
      assert {:target_id, "can't be blank"} in errors(Reaction.changeset(%{}))
    end

    test "validates that an adjustment is provided" do
      assert {:adjustment, "can't be blank"} in errors(Reaction.changeset(%{}))
    end
  end
end
