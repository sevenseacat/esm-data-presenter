defmodule Codex.AppliedMagicEffectTest do
  use Codex.ConnCase
  alias Codex.AppliedMagicEffect
  doctest Codex.AppliedMagicEffect

  test "has a valid factory" do
    assert insert(:applied_magic_effect)
  end

  describe "changeset/1" do
    test "validates that an attribute ID is not required" do
      refute {:attribute_id, "can't be blank"} in errors(AppliedMagicEffect.changeset(%{}))
    end

    test "validates that a provided attribute ID is valid" do
      params = :applied_magic_effect |> params_with_assocs |> Map.put(:attribute_id, -1)
      {:error, changeset} = params |> AppliedMagicEffect.changeset |> Repo.insert
      assert {:attribute_id, "does not exist"} in errors(changeset)
    end

    test "validates that a valid duration is provided" do
      assert {:duration, "can't be blank"} in errors(AppliedMagicEffect.changeset(%{}))
      assert {:duration, "is invalid"} in errors(AppliedMagicEffect.changeset(%{duration: "a"}))
      assert {:duration, "must be greater than or equal to 0"} in errors(AppliedMagicEffect.changeset(%{duration: -1}))
    end

    test "validates that a magic effect ID is provided" do
      assert {:magic_effect_id, "can't be blank"} in errors(AppliedMagicEffect.changeset(%{}))
    end

    test "validates that a valid magic effect ID is provided" do
      params = :applied_magic_effect |> params_with_assocs |> Map.put(:magic_effect_id, -1)
      {:error, changeset} = params |> AppliedMagicEffect.changeset |> Repo.insert
      assert {:magic_effect_id, "does not exist"} in errors(changeset)
    end

    test "validates that a valid minimum magnitude is provided" do
      assert {:magnitude_min, "can't be blank"} in errors(AppliedMagicEffect.changeset(%{}))
      assert {:magnitude_min, "is invalid"} in errors(AppliedMagicEffect.changeset(%{magnitude_min: "a"}))
      assert {:magnitude_min, "must be greater than or equal to 0"} in errors(AppliedMagicEffect.changeset(%{magnitude_min: -1}))
    end

    test "validates that a valid maximum magnitude is provided" do
      assert {:magnitude_max, "can't be blank"} in errors(AppliedMagicEffect.changeset(%{}))
      assert {:magnitude_max, "is invalid"} in errors(AppliedMagicEffect.changeset(%{magnitude_max: "a"}))
      assert {:magnitude_max, "must be greater than or equal to 0"} in errors(AppliedMagicEffect.changeset(%{magnitude_max: -1}))
    end

    test "validates that a skill ID is not required" do
      refute {:skill_id, "can't be blank"} in errors(AppliedMagicEffect.changeset(%{}))
    end

    test "validates that a provided skill ID is valid" do
      params = :applied_magic_effect |> params_with_assocs |> Map.put(:skill_id, -1)
      {:error, changeset} = params |> AppliedMagicEffect.changeset |> Repo.insert
      assert {:skill_id, "does not exist"} in errors(changeset)
    end

    test "validates that a valid type is provided" do
      assert {:type, "can't be blank"} in errors(AppliedMagicEffect.changeset(%{}))
      assert {:type, "is invalid"} in errors(AppliedMagicEffect.changeset(%{type: "not_valid"}))
      refute Keyword.has_key?(errors(AppliedMagicEffect.changeset(%{type: "self"})), :type)
    end

    test "validates that only one of a skill or attribute is provided" do
      changeset = :applied_magic_effect |> params_with_assocs |> Map.put(:skill_id, 1)
        |> Map.put(:attribute_id, 2) |> AppliedMagicEffect.changeset
      assert {:skill_id, "must be nil if an attribute ID is also provided"} in errors(changeset)
    end
  end
end
