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
    assert List.first(apparatuses) == %{id: "noob_tool", name: "Noob Tool", type: "mortar_pestle",
      script_id: "ToolScript", weight: 1.5, value: 12, quality: 2.7,
      model: "a\\A_Ebony_Boot_GND.nif", icon: "s\\B_Tx_S_fire_shield.dds"}
  end

  test "can read Armor data", %{stream: stream} do
    armor = stream |> Filter.by_type(:armor) |> Enum.to_list

    assert length(armor) == 1
    assert List.first(armor) == %{id: "hobs", name: "Helmet of Blinding Speed", type: "helmet",
      weight: 5.0, armor_rating: 7, health: 98, value: 1000, enchantment_points: 50,
      enchantment_id: nil, icon: nil, script_id: nil, model: nil}
  end

  test "can read Birthsign data", %{stream: stream} do
    birthsigns = stream |> Filter.by_type(:birthsign) |> Enum.to_list

    assert length(birthsigns) == 1
    assert List.first(birthsigns) == %{id: "steed", name: "Sign of the Cross",
      description: "The name of the rose", image: "_land_default.dds", skill_ids: ["pewpew"]}
  end

  test "can read Book data", %{stream: stream} do
    books = stream |> Filter.by_type(:book) |> Enum.to_list

    assert length(books) == 1
    assert List.first(books) == %{id: "Argonian Maid", name: "The Lusty Argonian Maid, Part 3",
      enchantment_points: 100, weight: 1.5, value: 50_000, model: "bam\\a_bonemold_bracers.nif",
      scroll: true, skill_id: 9, enchantment_id: nil, script_id: nil, icon: "m\\tx_gold_001.dds",
      text: "Something about polishing spears goes here."}
  end

  test "can read Cell data", %{stream: stream} do
    cells = stream |> Filter.by_type(:cell) |> Enum.to_list

    assert length(cells) == 1
    assert List.first(cells) == %{name: "Bedroom", water: true, interior: true, water_height: 5.0,
      sleep_illegal: false, behave_like_exterior: false, map_color: nil,
      ambient: "#1C7347", sunlight: "#F2D9D9", fog_color: "#D2D955", fog_density: 0.5,
      references: [
        %{name: "fargoth", key_id: nil, trap_id: nil, owner_id: nil, teleports_to: nil,
          lock_level: nil},
        %{name: "LootBag", key_id: nil, trap_id: nil, owner_id: nil, teleports_to: nil,
          lock_level: nil}
      ]}
  end

  test "can read Class data", %{stream: stream} do
    classes = stream |> Filter.by_type(:class) |> Enum.to_list

    assert length(classes) == 1
    assert List.first(classes) == %{id: "stuff", name: "Something",
      description: "A dummy class for test purposes.", attribute_1_id: 7, attribute_2_id: 2, specialization_id: 1,
      major_skill_ids: [0, 1, 2, 24, 4], minor_skill_ids: [5, 6, 7, 8, 3], playable: true,
      services: %{training: true, spellmaking: false, enchanting: false, repairing: false},
      vendors: %{weapons: true, armor: false, clothing: true, books: false, ingredients: false,
        picks: false, probes: false, lights: true, apparatus: false, repair_items: true,
        misc: false, spells: false, magic_items: false, potions: false}}
  end

  test "can read Clothing data", %{stream: stream} do
    clothing = stream |> Filter.by_type(:clothing) |> Enum.to_list

    assert length(clothing) == 1
    assert List.first(clothing) == %{id: "tshirt", name: "My Favorite T-Shirt", type: "shirt",
      enchantment_points: 300, weight: 2.0, value: 500, enchantment_id: "traveller", script_id: nil,
      icon: nil, model: nil}
  end

  test "can read Container data", %{stream: stream} do
    containers = stream |> Filter.by_type(:container) |> Enum.to_list

    assert length(containers) == 1
    assert List.first(containers) == %{id: "drawers", name: "T-Shirt Drawer", organic: true,
      model: nil, respawns: true, capacity: 50.0, items: [{10, "tshirt"}, {1, "hobs"}]}
  end

  test "can read Dialogue data", %{stream: stream} do
    dialogues = stream |> Filter.by_type(:dialogue) |> Enum.to_list
    assert length(dialogues) == 28 # Two I created, and lots of predefined ones

    goofed = Enum.find(dialogues, &(&1[:id] == "goofed"))
    assert %{id: "goofed", type: "topic", infos: [
      %{id: id_1, text: "Yes, I think you goofed.", previous_id: nil, next_id: id_2,
        disposition: 0, script: "; lol it worked!", gender: nil, npc_rank: nil,
        pc_rank: nil, faction_id: nil, race_id: nil, conditions: [
          %{function: "item", name: "Gold_010", operator: "=", value: 10}
        ]},
      %{id: id_2, text: "Nah, you're cool, %PCName.", previous_id: id_1, next_id: id_3,
        disposition: 0, script: nil, gender: nil, npc_rank: nil,
        pc_rank: nil, faction_id: nil, race_id: nil, conditions: [
          %{function: "dead", name: "fargoth", operator: "=", value: 1},
          %{function: "journal", name: "test_j", operator: "!=", value: 200},
          %{function: "not_faction", name: "ym_guild", operator: "=", value: 5}
        ]},
      %{id: id_3, text: "Huh?", previous_id: id_2, next_id: nil,
        disposition: 100, script: nil, faction_id: "ym_guild", npc_rank: 0, gender: :male,
        pc_rank: nil, race_id: nil, conditions: []}
    ]} = goofed

    greeting = Enum.find(dialogues, &(&1[:id] == "Greeting 0"))
    assert %{id: "Greeting 0", type: "greeting", infos: [
      %{id: _, text: "Oh God, I think you goofed.", previous_id: nil, next_id: nil,
        disposition: 25, script: nil, gender: nil, npc_rank: nil,
        pc_rank: nil, faction_id: nil, race_id: "other", conditions: [
          %{function: "not_id", name: "fargoth", operator: "=", value: 0}
        ]}]} = greeting
  end

  test "can read Enchantment data", %{stream: stream} do
    enchantments = stream |> Filter.by_type(:enchantment) |> Enum.to_list

    assert length(enchantments) == 1
    assert List.first(enchantments) == %{id: "traveller", type: "when_used", cost: 800,
      charge: 150, autocalc: false, enchantment_effects: [
        %{area: 0, attribute_id: nil, duration: 1, magic_effect_id: 63, magnitude_max: 1,
          magnitude_min: 1, skill_id: nil, type: "self"},
        %{area: 0, attribute_id: nil, duration: 1, magic_effect_id: 62, magnitude_max: 1,
          magnitude_min: 1, skill_id: nil, type: "self"},
        %{area: 5, attribute_id: nil, duration: 10, magic_effect_id: 89, magnitude_max: 3,
          magnitude_min: 2, skill_id: 14, type: "touch"}
      ]}
  end

  test "can read Faction data", %{stream: stream} do
    factions = stream |> Filter.by_type(:faction) |> Enum.to_list

    # "other guild" and "my guild"
    assert length(factions) == 2
    assert List.first(factions) == %{id: "ym_guild", name: "My Guild", hidden: false,
      attribute_1_id: 1, attribute_2_id: 2, favorite_skill_ids: [26, 25, 16, 5, 4, 3],
      reactions: [
        %{faction_id: "other_guild", adjustment: -5}, %{faction_id: "ym_guild", adjustment: 5}
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
     icon: "a\\Tx_Fur_Colovian_helm_r.dds", script_id: nil, model: nil, ingredient_effects: [
       %{skill_id: nil, attribute_id: nil, magic_effect_id: 132},
       %{skill_id: nil, attribute_id: nil, magic_effect_id: 23},
       %{skill_id: nil, attribute_id: nil, magic_effect_id: 47}]}
  end

  test "can read Journal data", %{stream: stream} do
    journals = stream |> Filter.by_type(:journal) |> Enum.to_list

    assert length(journals) == 1
    # Because it's a pattern match to ensure the unknown data is correct, it has to be on the LHS of
    # the assert. ExUnit will catch the MatchError and render an appropriate message, if it happens.
    # https://groups.google.com/forum/#!msg/elixir-lang-talk/4X0Ng0PJntQ/UPTznkD6TIUJ
    assert %{id: "test_j", infos: [
      %{id: id_1, previous_id: nil, next_id: id_2, index: 0, text: "Test Journal Name",
        name: true, complete: false, restart: false},
      %{id: id_2, previous_id: id_1, next_id: id_3, index: 10, text: "This is an index.",
        name: false, complete: false, restart: false},
      %{id: id_3, previous_id: id_2, next_id: id_4, index: 11, text: "Quest complete!",
        complete: true, name: false, restart: false},
      %{id: id_4, previous_id: id_3, next_id: id_5, index: 9, text: "Quest still complete!",
        complete: true, name: false, restart: false},
      %{id: id_5, previous_id: id_4, next_id: id_6, index: 100, text: "You dun goofed.",
        name: false, complete: false, restart: true},
      %{id: id_6, previous_id: id_5, next_id: nil, index: 500, text: "Complete again. Yay.",
        name: false, complete: true, restart: false}]
    } = List.first(journals)
  end

  test "can read Levelled Item data", %{stream: stream} do
    levelled_items = stream |> Filter.by_type(:levelled_item) |> Enum.to_list

    assert length(levelled_items) == 1
    assert List.first(levelled_items) == %{id: "stuff5", length: 3, chance_none: 10,
      calculate_for_all_levels: false, calculate_for_each_item: true, entries: [
        %{pc_level: 5, item_id: "tshirt"},
        %{pc_level: 10, item_id: "noob_tool"},
        %{pc_level: 99, item_id: "Misc_SoulGem_Azura"}
      ]}
  end

  test "can read Lockpick data", %{stream: stream} do
    lockpicks = stream |> Filter.by_type(:lockpick) |> Enum.to_list

    assert length(lockpicks) == 1
    assert List.first(lockpicks) == %{id: "pick", name: "Picky McPickFace",
      weight: 33.0, value: 44, uses: 55, quality: 22.0, icon: nil, model: nil, script_id: nil}
  end

  test "can read Magic Effect data", %{stream: stream} do
    effect = stream |> Filter.by_type(:magic_effect) |> Enum.find(&(&1[:name] == "Mark"))
    assert effect == %{id: 60, name: "Mark", skill_id: 14, base_cost: 15.0, spellmaking: true,
      enchanting: false, description: "Mark, then recall, for great justice.", negative: true,
      cast_sound: "Alteration Cast", cast_visual: "VFX_DefaultArea",
      bolt_sound: "Alteration Bolt", bolt_visual: nil,
      hit_sound: "Alteration Hit", hit_visual: nil,
      area_sound: "Alteration Area", area_visual: "VFX_DefaultCast",
      icon: "n\\tx_adamantium.dds", speed: 0.9, size: 1.0, size_cap: 25.0,
      particle_texture: nil, color: "#214263"}
  end

  test "can read Misc Item data", %{stream: stream} do
    misc_items = stream |> Filter.by_type(:misc_item) |> Enum.to_list
    assert length(misc_items) == 11

    soul_gem = Enum.find(misc_items, &(&1[:id] == "Misc_SoulGem_Petty"))
    assert soul_gem == %{id: "Misc_SoulGem_Petty", name: "Pretty Soul Gem",
      weight: 0.25, value: 11, model: "m\\misc_soulgem_petty.nif",
      icon: "m\\tx_soulgem_petty.tga", enchantment_id: nil, script_id: nil}
  end

  test "can read NPC data", %{stream: stream} do
    npcs = stream |> Filter.by_type(:npc) |> Enum.to_list

    assert length(npcs) == 1
    assert List.first(npcs) == %{id: "fargoth", name: "Son of Fargoth", race_id: "other",
      script_id: "DaughterOfFargoth", female: false, class_id: "stuff", level: 17,
      faction_id: "ym_guild", rank: 1, essential: true, respawn: false, autocalc: true,
      disposition: 50, skeleton_blood: true, metal_blood: false,
      items: [%{count: 1, id: "Argonian Maid"}], gold: 0, spell_ids: [],
      blocked: false, persistent: false}
  end

  test "can read Potion data", %{stream: stream} do
    potions = stream |> Filter.by_type(:potion) |> Enum.to_list

    assert length(potions) == 1
    assert List.first(potions) == %{id: "oops", name: "Not Skooma", script_id: "NotSkoomaScript",
      weight: 0.25, autocalc: true, value: 0, icon: nil, model: nil, effects: [
        %{magic_effect_id: 7, skill_id: nil, attribute_id: nil, duration: 5, magnitude_max: 20,
          magnitude_min: 20, area: 0, type: "self"},
        %{magic_effect_id: 8, skill_id: nil, attribute_id: nil, duration: 10, magnitude_max: 30,
          magnitude_min: 30, area: 0, type: "self"}
      ]}
  end

  test "can read Probe data", %{stream: stream} do
    probes = stream |> Filter.by_type(:probe) |> Enum.to_list

    assert length(probes) == 1
    assert List.first(probes) == %{id: "thing", name: "It's a Thing.", weight: 5.0, value: 10,
      uses: 73, quality: 1.18, icon: nil, model: nil, script_id: nil}
  end

  @tag :pending
  test "can read Race data", %{stream: _stream} do
  end

  test "can read Region data", %{stream: stream} do
    regions = stream |> Filter.by_type(:region) |> Enum.to_list

    assert length(regions) == 1
    assert List.first(regions) == %{id: "House", name: "My House", map_color: "#69E34A", weather:
      %{clear: 10, cloudy: 25, foggy: 35, overcast: 15, rain: 10, thunder: 0, ash: 0, blight: 0,
        snow: 5, blizzard: 0}}
  end

  test "can read Repair Item data", %{stream: stream} do
    repair_items = stream |> Filter.by_type(:repair) |> Enum.to_list

    assert length(repair_items) == 1
    assert List.first(repair_items) == %{id: "fixit", name: "Mr. Fixit", weight: 2.0, value: 7,
      uses: 11, quality: 1.0, icon: nil, model: "bab\\a_bear_boots.nif", script_id: nil}
  end

  test "can read Script data", %{stream: stream} do
    scripts = stream |> Filter.by_type(:script) |> Enum.to_list

    assert length(scripts) == 3 # ToolScript, DaughterOfFargoth, NotSkoomaScript
    assert List.first(scripts) == %{id: "DaughterOfFargoth",
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
    assert List.first(spells) == %{id: "pewpew", name: "Pew! Pew!", type: "spell", autocalc: true,
      starting_spell: true, always_succeeds: false, cost: 0, effects: [
        %{magic_effect_id: 85, attribute_id: 3, type: "target", area: 5, duration: 10,
          magnitude_min: 5, magnitude_max: 5, skill_id: nil},
        %{magic_effect_id: 25, attribute_id: nil, type: "self", area: 0, duration: 2,
          magnitude_min: 1, magnitude_max: 10, skill_id: nil}]}
  end

  test "can read Weapon data", %{stream: stream} do
    weapons = stream |> Filter.by_type(:weapon) |> Enum.to_list

    assert length(weapons) == 1
    assert List.first(weapons) == %{id: "pewpew2", name: "Axe of Pew Pew", type: "axe_2_hand",
      script_id: "NotSkoomaScript", weight: 5.0, health: 72, value: 18, speed: 1.5, reach: 0.5,
      silver: true, chop_min: 3, chop_max: 7, slash_min: 4, slash_max: 8, thrust_min: 5,
      thrust_max: 9, ignore_resistance: true, enchantment_id: nil, enchantment_points: 500,
      icon: nil, model: nil}
  end
end
