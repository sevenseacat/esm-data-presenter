defmodule Codex.Factory do
  @moduledoc """
  Defines some common factories, for quickly generating data for tests.
  """

  use ExMachina.Ecto, repo: Codex.Repo

  def attribute_factory do
    %Codex.Attribute{
      id: sequence(:id, &(&1)),
      name: "Test Attribute"
    }
  end

  def magic_effect_factory do
    %Codex.MagicEffect{
      id: 60,
      name: "Mark",
      skill: build(:skill),
      base_cost: 15.0,
      spellmaking: true,
      enchanting: false,
      description: "Mark, then recall, for great justice.",
      negative: true,
      icon: "n\\tx_adamantium.dds",
      speed: 0.9,
      size: 1.0,
      size_cap: 25.0,
      particle_texture: "a\\something.tga",
      color: "#214263"
    }
  end

  def script_factory do
    %Codex.Script{
      id: "test_script",
      text: "begin TestScript\r\n  ; script content\r\nend"
    }
  end

  def skill_factory do
    %Codex.Skill{
      id: sequence(:id, &(&1)),
      name: "Awesome Skill",
      description: "Now with added fireballs.",
      attribute: build(:attribute),
      specialization: build(:specialization)
    }
  end

  def specialization_factory do
    %Codex.Specialization{
      id: sequence(:id, &(&1)),
      name: "Stealth/Magic/Combat/HARBINGER OF DOOM"
    }
  end
end
