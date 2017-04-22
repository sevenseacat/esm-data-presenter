defmodule Codex.ScriptTest do
  use Codex.ConnCase
  alias Codex.Script
  doctest Codex.Script

  test "has a valid factory" do
    assert insert(:script)
  end

  describe "changeset/1" do
    test "validates that an ID is provided" do
      assert {:id, "can't be blank"} in errors(Script.changeset(%{}))
    end

    test "validates that text is provided" do
      assert {:text, "can't be blank"} in errors(Script.changeset(%{}))
    end
  end
end
