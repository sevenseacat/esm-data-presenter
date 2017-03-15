defmodule ParserTest do
  @moduledoc """
  These tests really test the EsmFile, EsmFormatter and Filter modules altogether - as such they've
  been lumped together into a common ParserTest module.
  """

  use ExUnit.Case
  alias Parser.{EsmFile, Filter}

  setup do
    {:ok, stream: EsmFile.stream("test/fixtures/Test.esm")}
  end

  test "can read Apparatus data", %{stream: stream} do
    apparatuses = stream |> Filter.by_type(:apparatus) |> Enum.to_list

    assert length(apparatuses) == 1
    assert List.first(apparatuses) == %{id: "noob_tool", name: "Noob Tool", type: :mortar_pestle,
      script: "ToolScript", weight: 1.5, value: 12, quality: 2.7, model: "a\\A_Ebony_Boot_GND.nif",
      texture: "s\\B_Tx_S_fire_shield.dds"}
  end

  test "can read Birthsign data", %{stream: stream} do
    birthsigns = stream |> Filter.by_type(:birthsign) |> Enum.to_list

    assert length(birthsigns) == 1
    assert List.first(birthsigns) == %{id: "steed", name: "Sign of the Cross",
      description: "The name of the rose", image: "_land_default.dds", skills: ["pewpew"]}
  end

  test "can read Book data", %{stream: stream} do
    books = stream |> Filter.by_type(:book) |> Enum.to_list

    assert length(books) == 1
    assert List.first(books) == %{id: "Argonian Maid", name: "The Lusty Argonian Maid, Part 3",
      enchantment_points: 100, weight: 1.5, value: 50_000, model: "bam\\a_bonemold_bracers.nif",
      scroll: true, skill_id: 9, enchantment_name: nil, script_name: nil,
      texture: "m\\tx_gold_001.dds", text: "Something about polishing spears goes here."}
  end

  test "can read Cell data", %{stream: stream} do
    cells = stream |> Filter.by_type(:cell) |> Enum.to_list

    assert length(cells) == 1
    assert List.first(cells) == %{name: "Bedroom", water: true, interior: true, water_height: 5.0,
      sleep_illegal: false, behave_like_exterior: false, map_color: nil,
      ambient: %{red: 28, green: 115, blue: 71},
      sunlight: %{red: 242, green: 217, blue: 217},
      fog: %{red: 210, green: 217, blue: 85, density: 0.5},
      references: [
        %{index: 1, name: "fargoth", key: nil, trap: nil, owner: nil},
        %{index: 2, name: "LootBag", key: nil, trap: nil, owner: nil}]}
  end

  test "can read Class data", %{stream: stream} do
    classes = stream |> Filter.by_type(:class) |> Enum.to_list

    assert length(classes) == 1
    assert List.first(classes) == %{id: "stuff", name: "Something",
      description: "A dummy class for test purposes.", attributes: [7, 2], specialization: 1,
      major_skills: [0, 1, 2, 24, 4], minor_skills: [5, 6, 7, 8, 3], playable: true,
      autocalc: %{weapon: true, armor: false, clothing: true, book: false, ingredient: false,
        pick: false, probe: false, light: true, apparatus: false, repair: true, misc: false,
        spell: false, magic_item: false, potion: false, training: true, spellmaking: false,
        enchanting: false, repair_item: false}}
  end

  test "can read Dialogue data", %{stream: stream} do
    dialogues = stream |> Filter.by_type(:dialogue) |> Enum.to_list
    assert length(dialogues) == 28 # Two I created, and lots of predefined ones

    goofed = Enum.find(dialogues, &(&1[:id] == "goofed"))
    assert %{id: "goofed", type: :topic, infos: [
      %{id: id_1, text: "Yes, I think you goofed.", previous: nil, next: id_2,
        disposition: 0, script: "; lol it worked!", gender: nil, npc_rank: nil,
        pc_rank: nil, faction: nil, race: nil, conditions: [
          %{index: 0, function: :item, name: "Gold_010", operator: "=", value: 10}
        ]},
      %{id: id_2, text: "Nah, you're cool, %PCName.", previous: id_1, next: id_3,
        disposition: 0, script: nil, gender: nil, npc_rank: nil,
        pc_rank: nil, faction: nil, race: nil, conditions: [
          %{index: 0, function: :dead, name: "fargoth", operator: "=", value: 1},
          %{index: 1, function: :journal, name: "test_j", operator: "!=", value: 200},
          %{index: 2, function: :not_faction, name: "ym_guild", operator: "=", value: 5}
        ]},
      %{id: id_3, text: "Huh?", previous: id_2, next: nil,
        disposition: 100, script: nil, faction: "ym_guild", npc_rank: 0, gender: :male,
        pc_rank: nil, race: nil, conditions: []}
    ]} = goofed

    greeting = Enum.find(dialogues, &(&1[:id] == "Greeting 0"))
    assert %{id: "Greeting 0", type: :greeting, infos: [
      %{id: _, text: "Oh God, I think you goofed.", previous: nil, next: nil,
        disposition: 25, script: nil, gender: nil, npc_rank: nil,
        pc_rank: nil, faction: nil, race: "other", conditions: [
          %{index: 0, function: :not_id, name: "fargoth", operator: "=", value: 0}
        ]}]} = greeting
  end

  test "can read Faction data", %{stream: stream} do
    factions = stream |> Filter.by_type(:faction) |> Enum.to_list

    # "other guild" and "my guild"
    assert length(factions) == 2
    assert List.first(factions) == %{id: "ym_guild", name: "My Guild", hidden: false,
      attribute_ids: [1, 2], favorite_skill_ids: [26, 25, 16, 5, 4, 3],
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

  test "can read Ingredient data", %{stream: stream} do
    ingredients = stream |> Filter.by_type(:ingredient) |> Enum.to_list

    assert length(ingredients) == 1
    assert List.first(ingredients) == %{id: "skooma", name: "Skooma", weight: 0.1, value: 500,
     icon: "a\\Tx_Fur_Colovian_helm_r.dds", script: nil, effects: [
       %{skill_id: nil, attribute_id: nil, effect_id: 132},
       %{skill_id: nil, attribute_id: nil, effect_id: 23},
       %{skill_id: nil, attribute_id: nil, effect_id: 47}]}
  end

  test "can read Journal data", %{stream: stream} do
    journals = stream |> Filter.by_type(:journal) |> Enum.to_list

    assert length(journals) == 1
    # Because it's a pattern match to ensure the unknown data is correct, it has to be on the LHS of
    # the assert. ExUnit will catch the MatchError and render an appropriate message, if it happens.
    # https://groups.google.com/forum/#!msg/elixir-lang-talk/4X0Ng0PJntQ/UPTznkD6TIUJ
    assert %{id: "test_j", infos: [
      %{id: id_1, previous: nil, next: id_2, index: 0, text: "Test Journal Name", name: true,
        complete: false, restart: false},
      %{id: id_2, previous: id_1, next: id_3, index: 10, text: "This is an index.", name: false,
        complete: false, restart: false},
      %{id: id_3, previous: id_2, next: id_4, index: 11, text: "Quest complete!", complete: true,
        name: false, restart: false},
      %{id: id_4, previous: id_3, next: id_5, index: 9, text: "Quest still complete!",
        complete: true, name: false, restart: false},
      %{id: id_5, previous: id_4, next: id_6, index: 100, text: "You dun goofed.", name: false,
        complete: false, restart: true},
      %{id: id_6, previous: id_5, next: nil, index: 500, text: "Complete again. Yay.", name: false,
        complete: true, restart: false}]
    } = List.first(journals)
  end

  @tag :pending
  test "can read Lockpick data", %{stream: _stream} do
  end

  test "can read Magic Effect data", %{stream: stream} do
    effect = stream |> Filter.by_type(:magic_effect) |> Enum.find(&(&1[:name] == "Mark"))
    assert effect == %{id: 60, name: "Mark", skill_id: 14, base_cost: 15.0, spellmaking: true,
      enchanting: false, description: "Mark, then recall, for great justice.", negative: true,
      cast_sound: "Alteration Cast", cast_visual: "VFX_DefaultArea",
      bolt_sound: "Alteration Bolt", bolt_visual: nil,
      hit_sound: "Alteration Hit", hit_visual: nil,
      area_sound: "Alteration Area", area_visual: "VFX_DefaultCast",
      icon_texture: "n\\tx_adamantium.dds", speed: 0.9, size: 1.0, size_cap: 25.0,
      particle_texture: nil, red: 33, green: 66, blue: 99}
  end

  test "can read Misc Item data", %{stream: stream} do
    misc_items = stream |> Filter.by_type(:misc_item) |> Enum.to_list

    assert length(misc_items) == 1
    assert List.first(misc_items) == %{id: "Misc_SoulGem_Petty", name: "Pretty Soul Gem",
      weight: 0.25, value: 11, model: "m\\misc_soulgem_petty.nif",
      texture: "m\\tx_soulgem_petty.tga", enchantment: nil, script: nil}
  end

  test "can read NPC data", %{stream: stream} do
    npcs = stream |> Filter.by_type(:npc) |> Enum.to_list

    assert length(npcs) == 1
    assert List.first(npcs) == %{id: "fargoth", name: "Son of Fargoth", script: "DaughterOfFargoth",
      race: "other", female: false, class: "stuff", level: 17, faction: "ym_guild", rank: 1,
      essential: true, respawn: false, autocalc: true, disposition: 50, skeleton_blood: true,
      metal_blood: false, items: [{1, "Argonian Maid"}], gold: 0, spells: []}
  end

  @tag :pending
  test "can read Probe data", %{stream: _stream} do
  end

  @tag :pending
  test "can read Race data", %{stream: _stream} do
  end

  test "can read Region data", %{stream: stream} do
    regions = stream |> Filter.by_type(:region) |> Enum.to_list

    assert length(regions) == 1
    assert List.first(regions) == %{id: "House", name: "My House", weather:
      %{clear: 10, cloudy: 25, foggy: 35, overcast: 15, rain: 10, thunder: 0, ash: 0, blight: 0,
        snow: 5, blizzard: 0},
      map_color: %{red: 105, green: 227, blue: 74}}
  end

  @tag :pending
  test "can read Repair Item data", %{stream: _stream} do
  end

  test "can read Script data", %{stream: stream} do
    scripts = stream |> Filter.by_type(:script) |> Enum.to_list

    assert length(scripts) == 2 # ToolScript and DaughterOfFargoth
    assert List.first(scripts) == %{name: "DaughterOfFargoth",
      text: "begin DaughterOfFargoth\r\n; does something?\r\nend"}
  end

  test "can read Skill data", %{stream: stream} do
    skill = stream |> Filter.by_type(:skill) |> Enum.find(&(&1[:name] == "Marksman"))
    assert skill == %{id: 23, name: "Marksman", attribute_id: 3, specialization_id: 2,
      description: "Hello world"}
  end

  test "can read Spell data", %{stream: stream} do
    spells = stream |> Filter.by_type(:spell) |> Enum.to_list

    assert length(spells) == 1
    assert List.first(spells) == %{id: "pewpew", name: "Pew! Pew!", type: :spell, autocalc: true,
      starting_spell: true, always_succeeds: false, cost: 0, effects: [
        %{effect_id: 85, attribute_id: 3, type: :target, area: 5, duration: 10, magnitude_min: 5,
          magnitude_max: 5, skill_id: nil},
        %{effect_id: 25, attribute_id: nil, type: :self, area: 0, duration: 2, magnitude_min: 1,
          magnitude_max: 10, skill_id: nil}]}
  end
end