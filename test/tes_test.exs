defmodule TesTest do
  use ExUnit.Case
  alias Tes.{EsmFile, Filter}

  setup do
    {:ok, stream: EsmFile.stream("test/fixtures/Test.esm")}
  end

  @tag :pending
  test "can read Apparatus data", %{stream: _stream} do
  end

  test "can read Birthsign data", %{stream: stream} do
    birthsigns = Filter.by_type(stream, :birthsign) |> Enum.to_list

    assert length(birthsigns) == 1
    assert List.first(birthsigns) == %{id: "steed", name: "Sign of the Cross",
      description: "The name of the rose", image: "_land_default.dds", skills: ["pewpew"] }
  end

  test "can read Book data", %{stream: stream} do
    books = Filter.by_type(stream, :book) |> Enum.to_list

    assert length(books) == 1
    assert List.first(books) == %{id: "Argonian Maid", name: "The Lusty Argonian Maid, Part 3",
      enchantment_points: 100, weight: 1.5, value: 50000, model: "bam\\a_bonemold_bracers.nif",
      scroll: true, skill_id: 9, enchantment_name: nil, script_name: nil,
      texture: "m\\tx_gold_001.dds", text: "Something about polishing spears goes here."}
  end

  @tag :pending
  test "can read Cell data", %{stream: _stream} do
  end

  test "can read Class data", %{stream: stream} do
    classes = Filter.by_type(stream, :class) |> Enum.to_list

    assert length(classes) == 1
    assert List.first(classes) == %{id: "stuff", name: "Something",
      description: "A dummy class for test purposes.", attributes: [7, 2], specialization: 1,
      major_skills: [0, 1, 2, 24, 4], minor_skills: [5, 6, 7, 8, 3], playable: true,
      autocalc: %{weapon: true, armor: false, clothing: true, book: false, ingredient: false,
        pick: false, probe: false, light: true, apparatus: false, repair: true, misc: false,
        spell: false, magic_item: false, potion: false, training: true, spellmaking: false,
        enchanting: false, repair_item: false}}
  end

  test "can read Dialogue data", %{stream: _stream} do
    assert false
  end

  test "can read Faction data", %{stream: stream} do
    factions = Tes.Filter.by_type(stream, :faction) |> Enum.to_list

    # "other guild" and "my guild"
    assert length(factions) == 2
    assert List.first(factions) == %{id: "ym_guild", name: "My Guild", hidden: false,
      attribute_1_id: 1, attribute_2_id: 2, favorite_skill_ids: [26, 25, 16, 5, 4, 3],
      reactions: [
        %{target_id: "ym_guild", adjustment: 5},
        %{target_id: "other_guild", adjustment: -5}
      ],
      ranks: [
        %{number: 1, name: "Rank A", attribute_1: 10, attribute_2: 10, skill_1: 20, skill_2: 15,
          reputation: 0},
        %{number: 2, name: "Rank B", attribute_1: 15, attribute_2: 12, skill_1: 20, skill_2: 20,
          reputation: 10}
      ]
    }
  end

  @tag :pending
  test "can read Ingredient data", %{stream: _stream} do
  end

  test "can read Journal data", %{stream: _stream} do
    assert false
  end

  test "can read Magic Effect data", %{stream: stream} do
    effect = Filter.by_type(stream, :magic_effect) |> Enum.find(&(&1[:name] == "Mark"))
    assert effect == %{id: 60, name: "Mark", skill_id: 14, base_cost: 15.0, spellmaking: true,
      enchanting: false, description: "Mark, then recall, for great justice.", negative: true,
      cast_sound: "Alteration Cast", cast_visual: "VFX_DefaultArea",
      bolt_sound: "Alteration Bolt", bolt_visual: nil,
      hit_sound: "Alteration Hit", hit_visual: nil,
      area_sound: "Alteration Area", area_visual: "VFX_DefaultCast",
      icon_texture: "n\\tx_adamantium.dds", speed: 0.9, size: 1.0, size_cap: 25.0,
      particle_texture: nil, red: 33, green: 66, blue: 99}
  end

  @tag :pending
  test "can read Misc Item data", %{stream: _stream} do
  end

  @tag :pending
  test "can read NPC data", %{stream: _stream} do
  end

  @tag :pending
  test "can read Race data", %{stream: _stream} do
    assert false
  end

  @tag :pending
  test "can read Region data", %{stream: _stream} do
  end

  test "can read Skill data", %{stream: stream} do
    skill = Filter.by_type(stream, :skill) |> Enum.find(&(&1[:name] == "Marksman"))
    assert skill == %{id: 23, name: "Marksman", attribute_id: 3, specialization_id: 2,
      description: "Hello world"}
  end

  test "can read Spell data", %{stream: stream} do
    spells = Filter.by_type(stream, :spell) |> Enum.to_list

    assert length(spells) == 1
    assert List.first(spells) == %{id: "pewpew", name: "Pew! Pew!", type: :spell, autocalc: true,
      starting_spell: true, always_succeeds: false, cost: 0, effects: [
        %{effect_id: 85, attribute_id: 3, type: :target, area: 5, duration: 10, magnitude_min: 5,
          magnitude_max: 5, skill_id: nil},
        %{effect_id: 25, attribute_id: nil, type: :self, area: 0, duration: 2, magnitude_min: 1,
          magnitude_max: 10, skill_id: nil}]}
  end
end
