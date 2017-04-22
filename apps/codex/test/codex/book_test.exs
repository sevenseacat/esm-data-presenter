defmodule Codex.BookTest do
  use Codex.ConnCase
  alias Codex.{Book, Repo}
  doctest Codex.Book

  test "has a valid factory" do
    assert insert(:book)
  end

  describe "changeset/1" do
    test "validates that a valid ID is present" do
      book = insert(:book)

      assert {:id, "can't be blank"} in errors(Book.changeset(%{}))
      assert {:error, changeset} = :book |> params_for(id: book.id) |> Book.changeset |> Repo.insert
      assert {:id, "has already been taken"} in errors(changeset)
    end

    test "validates that a name is present" do
      assert {:name, "can't be blank"} in errors(Book.changeset(%{}))
    end

    test "validates that a valid weight is provided" do
      assert {:weight, "can't be blank"} in errors(Book.changeset(%{}))
      assert {:weight, "is invalid"} in errors(Book.changeset(%{weight: "a"}))
      assert {:weight, "must be greater than or equal to 0"} in errors(Book.changeset(%{weight: -1}))
    end

    test "validates that a model is present" do
      assert {:model, "can't be blank"} in errors(Book.changeset(%{}))
    end

    test "validates whether it is a scroll or not" do
      assert {:scroll, "can't be blank"} in errors(Book.changeset(%{}))
    end

    test "validates that a valid value is provided" do
      assert {:value, "can't be blank"} in errors(Book.changeset(%{}))
      assert {:value, "is invalid"} in errors(Book.changeset(%{value: "a"}))
      assert {:value, "must be greater than or equal to 0"} in errors(Book.changeset(%{value: -1}))
    end

    test "validates that a valid enchantment point value is provided" do
      assert {:enchantment_points, "can't be blank"} in errors(Book.changeset(%{}))
      assert {:enchantment_points, "is invalid"} in
        errors(Book.changeset(%{enchantment_points: "a"}))
      assert {:enchantment_points, "must be greater than or equal to 0"} in
        errors(Book.changeset(%{enchantment_points: -1}))
    end

    test "validates that an icon is present" do
      assert {:icon, "can't be blank"} in errors(Book.changeset(%{}))
    end

    test "validates that any provided skill ID is valid" do
      {:error, changeset} = :book |> params_for |> Map.put(:skill_id, -1) |> Book.changeset
        |> Repo.insert
      assert {:skill_id, "does not exist"} in errors(changeset)
    end

    test "validates that any provided enchantment ID is valid" do
      {:error, changeset} = :book |> params_for |> Map.put(:enchantment_id, "not valid") |> Book.changeset
        |> Repo.insert
      assert {:enchantment_id, "does not exist"} in errors(changeset)
    end

    test "validates that any provided script ID is valid" do
      {:error, changeset} = :book |> params_for |> Map.put(:script_id, "not valid") |> Book.changeset
        |> Repo.insert
      assert {:script_id, "does not exist"} in errors(changeset)
    end
  end
end
