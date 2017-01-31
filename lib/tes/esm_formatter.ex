defmodule Tes.EsmFormatter do
  # Hardcoded things - there's a few of them
  @apparatus_types %{0 => :mortar_pestle, 1 => :alembic, 2 => :calcinator, 3 => :retort}

  @clothing_types %{0 => :pants, 1 => :shoes, 2 => :shirt, 3 => :belt, 4 => :robe,
    5 => :right_glove, 6 => :left_glove, 7 => :skirt, 8 => :ring, 9 => :amulet}

  @dialogue_types %{0 => :topic, 1 => :voice, 2 => :greeting, 3 => :persuasion, 4 => :journal}

  @dialogue_functions %{"00" => :rank_low, "01" => :rank_high, "02" => :rank_requirement,
    "03" => :reputation, "04" => :health_percent, "05" => :pc_reputation, "06" => :pc_level,
    "07" => :pc_health_percent, "08" => :pc_magicka, "09" => :pc_fatigue, "10" => :pc_strength,
    "11" => :pc_block, "12" => :pc_armorer, "13" => :pc_medium_armor, "14" => :pc_heavy_armor,
    "15" => :pc_blunt_weapon, "16" => :pc_long_blade, "17" => :pc_axe, "18" => :pc_spear,
    "19" => :pc_athletics, "20" => :pc_enchant, "21" => :pc_destruction, "22" => :pc_alteration,
    "23" => :pc_illusion, "24" => :pc_conjuration, "25" => :pc_mysticism,  "26" => :pc_restoration,
    "27" => :pc_alchemy, "28" => :pc_unarmored, "29" => :pc_security, "30" => :pc_sneak,
    "31" => :pc_acrobatics, "32" => :pc_light_armor, "33" => :pc_short_blade, "34" => :pc_marksman,
    "35" => :pc_mercantile, "36" => :pc_speechcraft, "37" => :pc_hand_to_hand, "38" => :pc_gender,
    "39" => :pc_expelled, "40" => :pc_common_disease, "41" => :pc_blight_disease,
    "42" => :pc_clothing_modifier, "43" => :pc_crime_level, "44" => :same_gender,
    "45" => :same_race, "46" => :same_faction, "47" => :faction_rank_diff, "48" => :detected,
    "49" => :alarmed, "50" => :choice, "51" => :pc_intelligence, "52" => :pc_willpower,
    "53" => :pc_agility, "54" => :pc_speed, "55" => :pc_endurance, "56" => :pc_personality,
    "57" => :pc_luck, "58" => :pc_corprus, "59" => :weather, "60" => :pc_vampire, "61" => :level,
    "62" => :attacked, "63" => :talked_to_pc, "64" => :pc_health, "65" => :creature_target,
    "66" => :friend_hit, "67" => :fight, "69" => :hello, "69" => :alarm, "70" => :flee,
    "71" => :should_attack, "sX" => :not_local, "JX" => :journal, "IX" => :item, "DX" => :dead,
    "XX" => :not_id, "FX" => :not_faction, "CX" => :not_class, "RX" => :not_race, "LX" => :not_cell,
    "fX" => :global}

  @dialogue_operations %{"0" => "=", "1" => "!=", "2" => ">", "3" => ">=", "4" => "<", "5" => "<="}

  @enchantment_types %{0 => :once, 1 => :on_strike, 2 => :when_used, 3 => :constant_effect}

  @magic_effect_names %{0 => "Water Breathing", 1 => "Swift Swim", 2 => "Water Walking",
    3 => "Shield", 4 => "Fire Shield", 5 => "Lightning Shield", 6 => "Frost Shield", 7 => "Burden",
    8 => "Feather", 9 => "Jump", 10 => "Levitate", 11 => "Slow Fall", 12 => "Lock", 13 => "Open",
    14 => "Fire Damage", 15 => "Shock Damage", 16 => "Frost Damage", 17 => "Drain Attribute",
    18 => "Drain Health", 19 => "Drain Magicka", 20 => "Drain Fatigue", 21 => "Drain Skill",
    22 => "Damage Attribute", 23 => "Damage Health", 24 => "Damage Magicka", 25 => "Damage Fatigue",
    26 => "Damage Skill", 27 => "Poison", 28 => "Weakness to Fire", 29 => "Weakness to Frost",
    30 => "Weakness to Shock", 31 => "Weakness to Magicka", 32 => "Weakness to Common Disease",
    33 => "Weakness to Blight Disease", 34 => "Weakness to Corprus Disease",
    35 => "Weakness to Poison", 36 => "Weakness to Normal Weapons", 37 => "Disintegrate Weapon",
    38 => "Disintegrate Armor", 39 => "Invisibility", 40 => "Chameleon", 41 => "Light",
    42 => "Sanctuary", 43 => "Night Eye", 44 => "Charm", 45 => "Paralyze", 46 => "Silence",
    47 => "Blind", 48 => "Sound", 49 => "Calm Humanoid", 50 => "Calm Creature",
    51 => "Frenzy Humanoid", 52 => "Frenzy Creature", 53 => "Demoralize Humanoid",
    54 => "Demoralize Creature", 55 => "Rally Humanoid", 56 => "Rally Creature", 57 => "Dispel",
    58 => "Soul Trap", 59 => "Telekinesis", 60 => "Mark", 61 => "Recall",
    62 => "Divine Intervention", 63 => "Almsivi Intervention", 64 => "Detect Animal",
    65 => "Detect Enchantment", 66 => "Detect Key", 67 => "Spell Absorption", 68 => "Reflect",
    69 => "Cure Common Disease", 70 => "Cure Blight Disease", 71 => "Cure Corprus Disease",
    72 => "Cure Poison", 73 => "Cure Paralyzation", 74 => "Restore Attribute",
    75 => "Restore Health", 76 => "Restore Magicka", 77 => "Restore Fatigue", 78 => "Restore Skill",
    79 => "Fortify Attribute", 80 => "Fortify Health", 81 => "Fortify Magicka",
    82 => "Fortify Fatigue", 83 => "Fortify Skill", 84 => "Fortify Maximum Magicka",
    85 => "Absorb Attribute", 86 => "Abosrb Health", 87 => "Absorb Magicka", 88 => "Absorb Fatigue",
    89 => "Absorb Skill", 90 => "Resist Fire", 91 => "Resist Frost", 92 => "Resist Shock",
    93 => "Resist Magicka", 94 => "Resist Common Disease", 95 => "Resist Blight Disease",
    96 => "Resist Corprus Disease", 97 => "Resist Poison", 98 => "Resist Normal Weapons",
    99 => "Resist Paralysis", 100 => "Remove Curse", 101 => "Turn Undead", 102 => "Summon Scamp",
    103 => "Summon Clannfear", 104 => "Summon Daedroth", 105 => "Summon Dremora",
    106 => "Summon Ancestral Ghost", 107 => "Summon Skeletal Minion", 108 => "Summon Bonewalker",
    109 => "Summon Greater Bonewalker", 110 => "Summon Bonelord", 111 => "Summon Winged Twilight",
    112 => "Summon Hunger", 113 => "Summon Golden Saint", 114 => "Summon Flame Atronach",
    115 => "Summon Frost Atronach", 116 => "Summon Storm Atronach", 117 => "Fortify Attack",
    118 => "Command Creature", 119 => "Command Humanoid", 120 => "Bound Dagger",
    121 => "Bound Longsword", 122 => "Bound Mace", 123 => "Bound Battleaxe", 124 => "Bound Spear",
    125 => "Bound Longbow", 126 => "Extra Spell", 127 => "Bound Cuirass", 128 => "Bound Helm",
    129 => "Bound Boots", 130 => "Bound Shield", 131 => "Bound Gloves", 132 => "Corprus",
    133 => "Vampirism", 134 => "Summon Centurion Sphere", 135 => "Sun Damage",
    136 => "Stunted Magicka", 137 => "Summon Fabricant", 138 => "Summon Wolf", 139 => "Summon Bear",
    140 => "Summon Bonewolf", 141 => "Summon Creature 04 ???", 142 => "Summon Creature 05 ???"}

  # Mapping school IDs to their actual skill IDs.
  @magic_effect_schools %{0 => 11, 1 => 13, 2 => 10, 3 => 12, 4 => 14, 5 => 15}

  @skill_names %{0 => "Block", 1 => "Armorer", 2 => "Medium Armor", 3 => "Heavy Armor",
    4 => "Blunt Weapon", 5 => "Long Blade", 6 => "Axe", 7 => "Spear", 8 => "Athletics",
    9 => "Enchant", 10 => "Destruction", 11 => "Alteration", 12 => "Illusion",
    13 => "Conjuration", 14 => "Mysticism", 15 => "Restoration", 16 => "Alchemy",
    17 => "Unarmored", 18 => "Security", 19 => "Sneak", 20 => "Acrobatics",
    21 => "Light Armor", 22 => "Short Blade", 23 => "Marksman", 24 => "Mercantile",
    25 => "Speechcraft", 26 => "Hand to Hand"}

  @spell_effect_types %{0 => :self, 1 => :touch, 2 => :target}

  @spell_types %{0 => :spell, 1 => :ability, 2 => :blight, 3 => :disease, 4 => :curse, 5 => :power}

  def build_record("APPA", %{"NAME" => id, "FNAM" => name, "AADT" => data} = raw_data) do
    {
      :apparatus,
      data
      |> Map.update!(:type, &(@apparatus_types[&1]))
      |> Map.merge(%{
        id: id,
        name: name,
        model: Map.get(raw_data, "MODL"),
        texture: Map.get(raw_data, "ITEX"),
        script: Map.get(raw_data, "SCRI")
      })
    }
  end

  def build_record("BOOK", %{"NAME" => id, "MODL" => model, "FNAM" => name, "BKDT" => bkdt} = raw_data) do
    {
      :book,
      %{
        id: id,
        name: name,
        model: model,
        weight: Map.get(bkdt, :weight),
        value: Map.get(bkdt, :value),
        scroll: Map.get(bkdt, :scroll),
        skill_id: Map.get(bkdt, :skill_id),
        enchantment_name: Map.get(raw_data, "ENAM"),
        enchantment_points: Map.get(bkdt, :enchantment),
        script_name: Map.get(raw_data, "SCRI"),
        texture: Map.get(raw_data, "ITEX"),
        text: Map.get(raw_data, "TEXT")
      }
    }
  end

  def build_record("BSGN", %{"NAME" => id, "FNAM" => name, "DESC" => desc, "NPCS" => skills,
    "TNAM" => texture}) do
    {
      :birthsign,
      %{
        id: id,
        name: name,
        description: desc,
        skills: skills,
        image: texture
      }
    }
  end

  def build_record("CELL", %{"NAME" => name}=raw_data) do
    {
      :cell,
      %{
        name: (if name == "", do: Map.get(raw_data, "RGNN"), else: name),
        water_height: Map.get(raw_data, "WHGT"),
        map_color: Map.get(raw_data, "NAM5"),
        references: Map.get(raw_data, "REFS", []) |> Enum.map(&format_cell_references/1) |> Enum.reverse
      }
      |> Map.merge(Map.get(raw_data, "DATA", %{}))
      |> Map.merge(Map.get(raw_data, "AMBI", %{}))
    }
  end

  def build_record("CLAS", %{"NAME" => id, "FNAM" => name, "CLDT" => cldt}=raw_data) do
    { :class,
      %{id: id,
        name: name,
        description: Map.get(raw_data, "DESC")}
      |> Map.merge(cldt)
    }
  end

  def build_record("CLOT", %{"NAME" => id, "FNAM" => name, "CTDT" => ctdt} = raw_data) do
    { :clothing,
      ctdt
      |> Map.update!(:type, &(Map.get(@clothing_types, &1)))
      |> Map.merge(%{
        id: id,
        name: name,
        model: Map.get(raw_data, "MODL"),
        texture: Map.get(raw_data, "ITEX"),
        enchantment: Map.get(raw_data, "ENAM"),
        script: Map.get(raw_data, "SCRI")
      })
    }
  end

  def build_record("DIAL", %{"NAME" => id, "DATA" => 4}) do
    { :journal, %{id: id, infos: []} }
  end

  def build_record("DIAL", %{"NAME" => id, "DATA" => type}) do
    { :dialogue, %{id: id, type: Map.fetch!(@dialogue_types, type), infos: []} }
  end

  def build_record("ENCH", %{"NAME" => id, "ENAM" => enam, "ENDT" => data}) do
    {
      :enchantment,
      data
      |> Map.update!(:type, &(@enchantment_types[&1]))
      |> Map.merge(%{
        id: id,
        effects: format_magic_effects(enam)
      })
    }
  end

  def build_record("FACT", %{"NAME" => id, "FNAM" => name, "FADT" => fadt} = raw_data) do
    {
      :faction,
      %{
        id: id,
        name: name,
        attribute_1_id: fadt |> Map.get(:attribute_ids) |> List.first,
        attribute_2_id: fadt |> Map.get(:attribute_ids) |> List.last,
        favorite_skill_ids: Map.get(fadt, :skill_ids),
        reactions: raw_data |> Map.get("ANAM/INTV", []) |> map_faction_reactions,
        hidden: Map.get(fadt, :flags) == 1,
        ranks: []
      }
      |> zip_faction_ranks(Map.get(raw_data, "RNAM", []), Map.get(fadt, :rankings))
    }
  end

  # Journal dialogue entries.
  def build_record("INFO", %{"DATA" => index} = raw_data) when is_integer(index) do
    { :info,
      raw_data
      |> common_dialogue_fields
      |> Map.merge(%{
        index: index,
        name: Map.get(raw_data, "QSTN") == 1,
        complete: Map.get(raw_data, "QSTF") == 1,
        restart: Map.get(raw_data, "QSTR") == 1
      })
    }
  end

  # Non-journal dialogue entries
  def build_record("INFO", %{"DATA" => data} = raw_data) when is_map(data) do
    { :info,
      raw_data
      |> common_dialogue_fields
      |> Map.merge(%{
        race: Map.get(raw_data, "RNAM"),
        faction: Map.get(raw_data, "FNAM"),
        conditions: raw_data |> Map.get("CONDS") |> readable_conditions,
        script: Map.get(raw_data, "BNAM")
      })
      |> Map.merge(data)
    }
  end

  def build_record("INGR", %{"NAME" => id, "FNAM" => name, "IRDT" => irdt}=raw_data) do
    {
      :ingredient,
      %{
        id: id,
        name: name,
        icon: Map.get(raw_data, "ITEX"),
        script: Map.get(raw_data, "SCRI")
      } |> Map.merge(irdt)
    }
  end

  def build_record("LOCK", %{"NAME" => id, "FNAM" => name, "LKDT" => data}=raw_data) do
    {
      :lockpick,
      %{
        id: id,
        name: name,
        model: Map.get(raw_data, "MODL"),
        texture: Map.get(raw_data, "ITEX"),
        script: Map.get(raw_data, "SCRI")
      } |> Map.merge(data)
    }
  end

  def build_record("MGEF", %{"INDX" => id, "MEDT" => medt} = raw_data) do
    {
      :magic_effect,
      medt
      |> Map.take([:base_cost, :red, :blue, :green, :speed, :size, :size_cap, :spellmaking,
        :enchanting, :negative])
      |> Map.merge(%{
        id: id,
        name: Map.get(@magic_effect_names, id),
        description: Map.get(raw_data, "DESC"),
        icon_texture: Map.get(raw_data, "ITEX"),
        particle_texture: Map.get(raw_data, "PTEX"),
        cast_visual: Map.get(raw_data, "CVFX"),
        bolt_visual: Map.get(raw_data, "BVFX"),
        hit_visual: Map.get(raw_data, "HVFX"),
        area_visual: Map.get(raw_data, "AVFX"),
        cast_sound: Map.get(raw_data, "CSND"),
        bolt_sound: Map.get(raw_data, "BSND"),
        hit_sound: Map.get(raw_data, "HSND"),
        area_sound: Map.get(raw_data, "ASND"),
        skill_id: Map.get(@magic_effect_schools, Map.get(medt, :school))
      })
    }
  end

  def build_record("MISC", %{"NAME" => id, "FNAM" => name, "MCDT" => data}=raw_data) do
    {
      :misc_item,
      %{
        id: id,
        name: name,
        model: Map.get(raw_data, "MODL"),
        texture: Map.get(raw_data, "ITEX"),
        enchantment: Map.get(raw_data, "ENAM"),
        script: Map.get(raw_data, "SCRI")
      } |> Map.merge(data)
    }
  end

  def build_record("PROB", %{"NAME" => id, "FNAM" => name, "PBDT" => data}=raw_data) do
    {
      :probe,
      %{
        id: id,
        name: name,
        model: Map.get(raw_data, "MODL"),
        texture: Map.get(raw_data, "ITEX"),
        script: Map.get(raw_data, "SCRI")
      } |> Map.merge(data)
    }
  end

  def build_record("RACE", %{"NAME" => id, "FNAM" => name, "RADT" => radt} = raw_data) do
    {
      :race,
      %{
        id: id,
        name: name,
        description: Map.get(raw_data, "DESC"),
        spells: Map.get(raw_data, "NPCS")
      }
      |> Map.merge(radt)
    }
  end

  # There are extra fields - BNAM = Sleep creature string and SNAM = Sound Records - not using them
  def build_record("REGN", %{"NAME" => id, "FNAM" => name, "WEAT" => weather, "CNAM" => color}) do
    {
      :region,
      %{
        id: id,
        name: name,
        map_color: color,
        weather: weather
      }
    }
  end

  def build_record("REPA", %{"NAME" => id, "FNAM" => name, "RIDT" => data}=raw_data) do
    {
      :repair,
      %{
        id: id,
        name: name,
        model: Map.get(raw_data, "MODL"),
        texture: Map.get(raw_data, "ITEX"),
        script: Map.get(raw_data, "SCRI")
      } |> Map.merge(data)
    }
  end

  # Script data contains lots of compilation data, but we just want the raw text
  def build_record("SCPT", %{"SCHD" => header, "SCTX" => text}) do
    {
      :script,
      %{name: Map.get(header, :name), text: text}
    }
  end

  def build_record("SKIL", %{"INDX" => id, "SKDT" => skdt, "DESC" => desc}) do
    {
      :skill,
      %{
        id: id,
        name: Map.get(@skill_names, id),
        attribute_id: Map.get(skdt, :attribute_id),
        specialization_id: Map.get(skdt, :specialization_id),
        description: desc
      }
    }
  end

  def build_record("SPEL", %{"NAME" => id, "FNAM" => name, "ENAM" => enam} = raw_data) do
    {
      :spell,
      raw_data
      |> Map.get("SPDT")
      |> Map.update!(:type, &(Map.get(@spell_types, &1)))
      |> Map.merge(%{
        id: id,
        name: name,
        effects: format_magic_effects(enam)
      })
    }
  end

  def build_record(type, subrecords), do: {type, subrecords}

  defp zip_faction_ranks(faction, [], _), do: faction
  defp zip_faction_ranks(faction, [name | names], [rank | ranks]) do
    faction
    |> Map.update!(:ranks, fn ranks -> ranks ++ [Map.put(rank, :name, name)] end)
    |> zip_faction_ranks(names, ranks)
  end

  defp map_faction_reactions(tuples) do
    Enum.map(tuples, fn({target, adjustment}) -> %{target_id: target, adjustment: adjustment} end)
  end

  defp common_dialogue_fields(raw_data) do
    %{
      id: Map.get(raw_data, "INAM"),
      text: Map.get(raw_data, "NAME"),
      previous: Map.get(raw_data, "PNAM"),
      next: Map.get(raw_data, "NNAM")
    }
  end

  defp readable_conditions(nil), do: []
  defp readable_conditions(conditions), do: Enum.map(conditions, &condition/1) |> Enum.reverse
  defp condition({%{function: fun, index: index, name: name, operator: op}, value}) do
    %{
      index: String.to_integer(index),
      function: Map.fetch!(@dialogue_functions, fun),
      name: name,
      operator: Map.fetch!(@dialogue_operations, op),
      value: value
    }
  end

  defp format_magic_effects(effects) do
    Enum.map(effects, fn effect ->
      Map.update!(effect, :type, &(Map.get(@spell_effect_types, &1)))
    end)
  end

  def format_cell_references(reference) do
    %{
      index: Map.get(reference, "index"),
      name: Map.get(reference, "NAME"),
      key: Map.get(reference, "KNAM"),
      trap: Map.get(reference, "TNAM"),
      owner: Map.get(reference, "ANAM")
    }
  end
end
