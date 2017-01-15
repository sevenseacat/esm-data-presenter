defmodule TesTest do
  use ExUnit.Case
  alias Tes.{EsmFile, Filter}

  setup do
    {:ok, stream: EsmFile.stream("test/fixtures/Test.esm")}
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
end
