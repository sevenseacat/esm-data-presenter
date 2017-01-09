defmodule Tes.EsmFormatter do
  # Hardcoded things - there's a few of them
  @skill_names %{0 => "Block", 1 => "Armorer", 2 => "Medium Armor", 3 => "Heavy Armor",
    4 => "Blunt Weapon", 5 => "Long Blade", 6 => "Axe", 7 => "Spear", 8 => "Athletics",
    9 => "Enchant", 10 => "Destruction", 11 => "Alteration", 12 => "Illusion",
    13 => "Conjuration", 14 => "Mysticism", 15 => "Restoration", 16 => "Alchemy",
    17 => "Unarmored", 18 => "Security", 19 => "Sneak", 20 => "Acrobatics",
    21 => "Light Armor", 22 => "Short Blade", 23 => "Marksman", 24 => "Mercantile",
    25 => "Speechcraft", 26 => "Hand to Hand"}

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

  def build_record("BSGN", %{"NAME" => key, "FNAM" => name, "DESC" => desc, "NPCS" => skills}) do
    {
      :birthsign,
      %{
        key: key,
        name: name,
        description: desc,
        skills: skills
      }
    }
  end

  def build_record("SPEL", %{"NAME" => id, "FNAM" => name, "SPDT" => spdt, "ENAM" => enam}) do
    {
      :spell,
      %{
        id: id,
        name: name,
        effects: enam
      }
      |> Map.merge(spdt)
    }
  end

  def build_record("MGEF", %{"INDX" => id, "DESC" => description, "MEDT" => medt} = raw_data) do
    {
      :magic_effect,
      %{
        id: id,
        name: Map.get(@magic_effect_names, id),
        description: description,
        icon_texture: Map.get(raw_data, "ITEX"),
        particle_texture: Map.get(raw_data, "PTEX"),
        casting_visual: Map.get(raw_data, "CVFX"),
        bolt_visual: Map.get(raw_data, "BVFX"),
        hit_visual: Map.get(raw_data, "HVFX"),
        area_visual: Map.get(raw_data, "AVFX"),
        cast_sound: Map.get(raw_data, "CSND"),
        bolt_sound: Map.get(raw_data, "BSND"),
        hit_sound: Map.get(raw_data, "HSND"),
        area_sound: Map.get(raw_data, "ASND")
      }
      |> Map.merge(medt)
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

  def build_record("DIAL", %{"NAME" => name, "DATA" => type}) do
    { :dialogue, %{name: name, type: type} }
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
end
