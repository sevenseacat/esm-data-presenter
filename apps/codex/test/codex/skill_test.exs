defmodule Codex.SkillTest do
  use Codex.ConnCase
  alias Codex.{Repo, Skill}

  test "has a valid factory" do
    assert insert(:skill)
  end

  describe "changeset/1" do
    test "validates that an ID is provided" do
      assert {:id, "can't be blank"} in errors(Skill.changeset(%{}))
    end

    test "validates that a name is provided" do
      assert {:name, "can't be blank"} in errors(Skill.changeset(%{}))
    end

    test "validates that a description is provided" do
      assert {:description, "can't be blank"} in errors(Skill.changeset(%{}))
    end

    test "validates that an attribute ID is provided" do
      assert {:attribute_id, "can't be blank"} in errors(Skill.changeset(%{}))
    end

    test "validates that the attribute ID provided is valid" do
      params = params_with_assocs(:skill)
      {:error, changeset} = params |> Map.put(:attribute_id, -1) |> Skill.changeset |> Repo.insert

      assert {:attribute_id, "does not exist"} in errors(changeset)
      assert {:ok, _skill} = params |> Skill.changeset |> Repo.insert
    end

    test "validates that a specialization ID is provided" do
      assert {:specialization_id, "can't be blank"} in errors(Skill.changeset(%{}))
    end

    test "validates that the specialization ID provided is valid" do
      params = params_with_assocs(:skill)
      {:error, changeset} = params |> Map.put(:specialization_id, -1) |> Skill.changeset
        |> Repo.insert

      assert {:specialization_id, "does not exist"} in errors(changeset)
      assert {:ok, _skill} = params |> Skill.changeset |> Repo.insert
    end
  end
end
