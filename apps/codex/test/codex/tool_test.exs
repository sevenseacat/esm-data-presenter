defmodule Codex.ToolTest do
  use Codex.ConnCase
  alias Codex.Tool
  doctest Codex.Tool

  test "has a valid factory" do
    assert insert(:tool)
  end

  describe "changeset/1" do
    test "validates that a valid ID is present" do
      tool = insert(:tool)

      assert {:id, "can't be blank"} in errors(Tool.changeset(%{}))
      assert {:error, changeset} = :tool |> params_for(id: tool.id) |> Tool.changeset
        |> Repo.insert
      assert {:id, "has already been taken"} in errors(changeset)
    end

    test "validates that a name is present" do
      assert {:name, "can't be blank"} in errors(Tool.changeset(%{}))
    end

    test "validates that a valid weight is present" do
      assert {:weight, "can't be blank"} in errors(Tool.changeset(%{}))
      assert {:weight, "is invalid"} in errors(Tool.changeset(%{weight: "a"}))
      assert {:weight, "must be greater than or equal to 0"} in errors(Tool.changeset(%{weight: -1}))
    end

    test "validates that a valid value is provided" do
      assert {:value, "can't be blank"} in errors(Tool.changeset(%{}))
      assert {:value, "is invalid"} in errors(Tool.changeset(%{value: "a"}))
      assert {:value, "must be greater than or equal to 0"} in errors(Tool.changeset(%{value: -1}))
    end

    test "validates that a model is present" do
      assert {:model, "can't be blank"} in errors(Tool.changeset(%{}))
    end

    test "validates that an icon is present" do
      assert {:icon, "can't be blank"} in errors(Tool.changeset(%{}))
    end

    test "validates that a valid quality is provided" do
      assert {:quality, "can't be blank"} in errors(Tool.changeset(%{}))
      assert {:quality, "is invalid"} in errors(Tool.changeset(%{quality: "a"}))
      assert {:quality, "must be greater than 0"} in errors(Tool.changeset(%{quality: 0}))
    end

    test "validates that a valid number of uses is provided" do
      assert {:uses, "can't be blank"} in errors(Tool.changeset(%{}))
      assert {:uses, "is invalid"} in errors(Tool.changeset(%{uses: "a"}))
      assert {:uses, "must be greater than 0"} in errors(Tool.changeset(%{uses: 0}))
    end

    test "validates that an valid type is present" do
      assert {:type, "can't be blank"} in errors(Tool.changeset(%{}))
      assert {:type, "is invalid"} in errors(Tool.changeset(%{type: "magic_tool"}))
      refute {:type, "is invalid"} in errors(Tool.changeset(%{type: "probe"}))
      refute {:type, "is invalid"} in errors(Tool.changeset(%{type: "lockpick"}))
    end
  end
end
