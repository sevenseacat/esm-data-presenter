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

  def enchantment_effect_factory do
    %Codex.Enchantment.Effect{
      enchantment: build(:enchantment),
      attribute: build(:attribute),
      magic_effect: build(:magic_effect),
      skill: build(:skill),
      type: "self",
      area: 0,
      duration: 10,
      magnitude_max: 1,
      magnitude_min: 10
    }
  end

  def enchantment_factory do
    %Codex.Enchantment{
      id: "pew_pew",
      type: "when_used",
      cost: 100,
      charge: 500,
      autocalc: false
    }
  end

  def faction_factory do
    %Codex.Faction{
      id: sequence(:id, &("my_faction_#{&1}")),
      name: "My Faction",
      attribute_1: build(:attribute),
      attribute_2: build(:attribute),
      hidden: false
    }
  end

  def faction_rank_factory do
    %Codex.Faction.Rank{
      faction: build(:faction),
      number: 1,
      name: "Rank 1",
      attribute_1: 10,
      attribute_2: 10,
      skill_1: 20,
      skill_2: 5,
      reputation: 10
    }
  end

  def faction_reaction_factory do
    faction = insert(:faction)

    %Codex.Faction.Reaction{
      source: faction,
      target: faction,
      adjustment: 2
    }
  end

  def magic_effect_factory do
    %Codex.MagicEffect{
      id: sequence(:id, &(&1)),
      name: sequence(:name, &("Mark#{&1}")),
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
