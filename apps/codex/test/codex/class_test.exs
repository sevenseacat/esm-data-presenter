defmodule Codex.ClassTest do
  use Codex.ConnCase
  alias Codex.Class
  doctest Codex.Class

  test "has a valid factory" do
    assert insert(:class)
  end

  describe "changeset/1" do
    test "validates that a valid ID is provided" do
      class = insert(:class)

      assert {:id, "can't be blank"} in errors(Class.changeset(%{}))
      assert {:error, changeset} = parsed_class_params() |> Map.put(:id, class.id)
        |> Class.changeset |> Repo.insert
      assert {:id, "has already been taken"} in errors(changeset)
    end

    test "validates that a valid specialization ID is provided" do
      assert {:specialization_id, "can't be blank"} in errors(Class.changeset(%{}))
    end

    test "validates that two attribute IDs are provided" do
      assert {:attribute_1_id, "can't be blank"} in errors(Class.changeset(%{}))
      assert {:attribute_2_id, "can't be blank"} in errors(Class.changeset(%{}))
    end

    test "validates that the first attribute ID provided is valid" do
      {:error, changeset} = parsed_class_params() |> Map.put(:attribute_1_id, -1) |> Class.changeset
        |> Repo.insert
      assert {:attribute_1_id, "does not exist"} in errors(changeset)
    end

    test "validates that the second attribute ID provided is valid" do
      {:error, changeset} = parsed_class_params() |> Map.put(:attribute_2_id, -1) |> Class.changeset
        |> Repo.insert
      assert {:attribute_2_id, "does not exist"} in errors(changeset)
    end

    test "validates that exactly five major skill IDs are required" do
      skill_ids = 6 |> insert_list(:skill) |> Enum.map(&(&1.id))

      errors = %{major_skill_ids: Enum.take(skill_ids, 4)} |> Class.changeset |> errors
      assert {:major_skills, "should have 5 item(s)"} in errors

      errors = %{major_skill_ids: Enum.take(skill_ids, 6)} |> Class.changeset |> errors
      assert {:major_skills, "should have 5 item(s)"} in errors

      errors = %{major_skill_ids: Enum.take(skill_ids, 5)} |> Class.changeset |> errors
      refute {:major_skills, "should have 5 item(s)"} in errors
    end

    test "validates that exactly five minor skill IDs are required" do
      skill_ids = 6 |> insert_list(:skill) |> Enum.map(&(&1.id))

      errors = %{minor_skill_ids: Enum.take(skill_ids, 4)} |> Class.changeset |> errors
      assert {:minor_skills, "should have 5 item(s)"} in errors

      errors = %{minor_skill_ids: Enum.take(skill_ids, 6)} |> Class.changeset |> errors
      assert {:minor_skills, "should have 5 item(s)"} in errors

      errors = %{minor_skill_ids: Enum.take(skill_ids, 5)} |> Class.changeset |> errors
      refute {:minor_skills, "should have 5 item(s)"} in errors
    end
  end
end
