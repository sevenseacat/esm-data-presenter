defmodule Codex.Faction.ReactionTest do
  use Codex.ConnCase
  alias Codex.{Faction.Reaction, Repo}

  test "has a valid factory" do
    assert insert(:faction_reaction)
  end

  describe "changeset/2" do
    test "validates that a source faction ID is provided" do
      assert {:source_id, "can't be blank"} in errors(Reaction.changeset(%{}))
    end

    test "validates that the source faction ID is valid" do
      params = params_with_assocs(:faction_reaction)
      # ex_machina provides the keys in a slightly different format than the parser provides
      fixed_params = params |> Map.put(:faction_id, params[:target_id])
      {:error, changeset} = %Reaction{source_id: "no"} |> Reaction.changeset(fixed_params)
        |> Repo.insert
      assert {:source_id, "does not exist"} in errors(changeset)
    end

    test "validates that a target faction ID is provided" do
      assert {:target_id, "can't be blank"} in errors(Reaction.changeset(%{}))
    end

    test "validates that an adjustment is provided" do
      assert {:adjustment, "can't be blank"} in errors(Reaction.changeset(%{}))
    end
  end
end
