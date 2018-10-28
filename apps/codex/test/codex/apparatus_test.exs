defmodule Codex.ApparatusTest do
  use Codex.ConnCase
  alias Codex.Apparatus
  #doctest Codex.Apparatus

  test "has a valid factory" do
    assert insert(:apparatus)
  end

  describe "changeset/1" do
    test "validates that a valid ID is present" do
      apparatus = insert(:apparatus)

      assert {:id, "can't be blank"} in errors(Apparatus.changeset(%{}))
      assert {:error, changeset} = :apparatus |> params_for(id: apparatus.id) |> Apparatus.changeset
        |> Repo.insert
      assert {:id, "has already been taken"} in errors(changeset)
    end

    test "validates that a name is present" do
      assert {:name, "can't be blank"} in errors(Apparatus.changeset(%{}))
    end

    test "validates that a valid weight is present" do
      assert {:weight, "can't be blank"} in errors(Apparatus.changeset(%{}))
      assert {:weight, "is invalid"} in errors(Apparatus.changeset(%{weight: "a"}))
      assert {:weight, "must be greater than or equal to 0"} in errors(Apparatus.changeset(%{weight: -1}))
    end

    test "validates that a valid value is provided" do
      assert {:value, "can't be blank"} in errors(Apparatus.changeset(%{}))
      assert {:value, "is invalid"} in errors(Apparatus.changeset(%{value: "a"}))
      assert {:value, "must be greater than or equal to 0"} in errors(Apparatus.changeset(%{value: -1}))
    end

    test "validates that a model is present" do
      assert {:model, "can't be blank"} in errors(Apparatus.changeset(%{}))
    end

    test "validates that an icon is present" do
      assert {:icon, "can't be blank"} in errors(Apparatus.changeset(%{}))
    end

    test "validates that a valid quality is provided" do
      assert {:quality, "can't be blank"} in errors(Apparatus.changeset(%{}))
      assert {:quality, "is invalid"} in errors(Apparatus.changeset(%{quality: "a"}))
      assert {:quality, "must be greater than 0"} in errors(Apparatus.changeset(%{quality: 0}))
    end

    test "validates that an valid type is present" do
      assert {:type, "can't be blank"} in errors(Apparatus.changeset(%{}))
      assert {:type, "is invalid"} in errors(Apparatus.changeset(%{type: "magic_tool"}))
      refute {:type, "is invalid"} in errors(Apparatus.changeset(%{type: "alembic"}))
      refute {:type, "is invalid"} in errors(Apparatus.changeset(%{type: "retort"}))
    end
  end
end
