defmodule Codex.MagicEffectTest do
  use Codex.ConnCase
  alias Codex.{MagicEffect, Repo}

  test "has a valid factory" do
    assert insert(:magic_effect)
  end

  describe "changeset/1" do
    test "validates that an ID is provided" do
      assert {:id, "can't be blank"} in errors(MagicEffect.changeset(%{}))
    end

    test "validates that a name is provided" do
      assert {:name, "can't be blank"} in errors(MagicEffect.changeset(%{}))
    end

    test "validates that a skill ID is provided" do
      assert {:skill_id, "can't be blank"} in errors(MagicEffect.changeset(%{}))
    end

    test "validates that the skill ID provided is valid" do
      params = params_with_assocs(:magic_effect)
      {:error, changeset} = params |> Map.put(:skill_id, -1) |> MagicEffect.changeset |> Repo.insert

      assert {:skill_id, "does not exist"} in errors(changeset)
      assert {:ok, _effect} = params |> MagicEffect.changeset |> Repo.insert
    end

    test "validates that a base cost is provided" do
      assert {:base_cost, "can't be blank"} in errors(MagicEffect.changeset(%{}))
    end

    test "validates that an icon is provided" do
      assert {:icon, "can't be blank"} in errors(MagicEffect.changeset(%{}))
    end

    test "validates that a speed is provided" do
      assert {:speed, "can't be blank"} in errors(MagicEffect.changeset(%{}))
    end

    test "validates that a size is provided" do
      assert {:size, "can't be blank"} in errors(MagicEffect.changeset(%{}))
    end

    test "validates that a size cap is provided" do
      assert {:size_cap, "can't be blank"} in errors(MagicEffect.changeset(%{}))
    end

    test "validates that a particle texture is provided" do
      assert {:particle_texture, "can't be blank"} in errors(MagicEffect.changeset(%{}))
    end

    test "validates that a colour is provided" do
      assert {:color, "can't be blank"} in errors(MagicEffect.changeset(%{}))
    end
  end
end
