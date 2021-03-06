defmodule Parser.EsmFile do
  @moduledoc """
  The main module providing functions for parsing an ESM file.

  File format interpreted from http://www.uesp.net/morrow/tech/mw_esm.txt
  """

  import Bitwise, only: [band: 2]
  import VariableSizes
  alias Parser.EsmFormatter

  @source_file Application.app_dir(:parser, "priv/Morrowind.esm")

  @doc """
  Creates a stream of data parsed from the named ESM file.

  Uses `Parser.EsmFormatter.build_record/2` for formatting each record in the stream when read.

  ## Examples

      iex> Parser.EsmFile.stream |> Stream.run
      [{:book, %{...}}, {:weapon, %{...}}, ...]
  """
  @spec stream(filename :: String.t()) :: %Stream{}
  def stream(filename \\ @source_file) do
    Stream.resource(
      fn -> File.open!(filename, [:binary]) end,
      fn file -> next_record(file) end,
      fn file -> File.close(file) end
    )
  end

  defp next_record(file) do
    case IO.binread(file, 16) do
      :eof ->
        {:halt, file}

      <<type::binary-4, size::long, _header1::bytes-4, flags::long>> ->
        subrecords = file |> IO.binread(size) |> parse_sub_records(type, %{})
        flags = parse_bitmask(flags, blocked: 0x00002000, persistent: 0x00000400)
        {[EsmFormatter.build_record(type, subrecords, flags)], file}
    end
  end

  defp parse_sub_records("", _type, list), do: list

  defp parse_sub_records(<<name::binary-4, size::long, rest::binary>>, type, list) do
    # Split the "rest" out into the content for this sub-record, and the rest
    value = binary_part(rest, 0, size)
    rest = binary_part(rest, size, byte_size(rest) - size)

    new_list = record_value(list, type, name, format_value(type, name, value))
    parse_sub_records(rest, type, new_list)
  end

  ##############################
  # How values should be stored
  # eg. as a primitive value, or a key-value tuple, or a list
  ##############################

  defp record_value(list, "CELL", "FRMR", value) do
    record_list_map_key(list, "REFS", "index", value)
  end

  # Name and data appear multiple times for a cell - once for the cell itself, once for each ref
  defp record_value(list, "CELL", name, value) when name in ["NAME", "DATA", "INTV"] do
    if Map.has_key?(list, "REFS") do
      record_list_map_value(list, "REFS", name, value)
    else
      Map.put_new(list, name, value)
    end
  end

  defp record_value(list, "CELL", name, value)
       when name in [
              "XSCL",
              "DELE",
              "DODT",
              "DNAM",
              "FLTV",
              "KNAM",
              "TNAM",
              "UNAM",
              "ANAM",
              "BNAM",
              "NAM9",
              "XSOL",
              "DATA"
            ] do
    record_list_map_value(list, "REFS", name, value)
  end

  defp record_value(list, "CONT", "NPCO", value), do: record_list(list, "ITEM", value)
  defp record_value(list, "FACT", "RNAM", value), do: record_list(list, "RNAM", value)

  defp record_value(list, "FACT", "ANAM", value), do: record_pair_key(list, "ANAM/INTV", value)
  defp record_value(list, "FACT", "INTV", value), do: record_pair_value(list, "ANAM/INTV", value)

  defp record_value(list, "INFO", "SCVR", value), do: record_pair_key(list, "CONDS", value)
  defp record_value(list, "INFO", "INTV", value), do: record_pair_value(list, "CONDS", value)
  defp record_value(list, "INFO", "FLTV", value), do: record_pair_value(list, "CONDS", value)

  defp record_value(list, "LEVI", "INAM", value), do: record_pair_key(list, "ENTR", value)
  defp record_value(list, "LEVI", "INTV", value), do: record_pair_value(list, "ENTR", value)

  defp record_value(list, "NPC_", "NPCO", value), do: record_list(list, "NPCO", value)

  defp record_value(list, _type, "NPCS", value), do: record_list(list, "NPCS", value)

  defp record_value(list, type, "ENAM", value) when type in ["ALCH", "ENCH", "SPEL"] do
    record_list(list, "ENAM", value)
  end

  defp record_value(list, _type, name, value), do: Map.put_new(list, name, value)

  ###############################
  # For field-specific formatting.
  # eg. some fields are null-terminated strings, some are bitmasks, some are little-endian integers
  ###############################

  defp format_value(_type, name, value)
       when name in ["NAME", "FNAM", "DESC", "MAST", "NPCS", "ITEX", "PTEX", "SCRI"] do
    value
    |> strip_null
    |> String.replace(<<146>>, "’")
  end

  defp format_value(_type, "INDX", <<id::long>>), do: id

  defp format_value(_type, "MODL", value) do
    value
    |> strip_null
    |> case do
      "Add World Art" -> nil
      "Add Art File" -> nil
      other -> other
    end
  end

  defp format_value("ALCH", "TEXT", value), do: strip_null(value)

  defp format_value("ALCH", "ALDT", <<weight::lfloat, value::long, autocalc::long>>) do
    %{weight: weight, value: value, autocalc: autocalc == 1}
  end

  defp format_value("APPA", "AADT", <<type::long, quality::lfloat, weight::lfloat, value::long>>) do
    %{type: type, weight: float(weight), value: value, quality: float(quality)}
  end

  defp format_value(
         "ARMO",
         "AODT",
         <<type::long, weight::lfloat, value::long, health::long, enchantment_points::long,
           armor::long>>
       ) do
    %{
      type: type,
      weight: float(weight),
      value: value,
      health: health,
      enchantment_points: enchantment_points,
      armor_rating: armor
    }
  end

  defp format_value(type, "ENAM", value) when type in ["ARMO", "BOOK", "CLOT", "WEAP"] do
    strip_null(value)
  end

  defp format_value(
         "BOOK",
         "BKDT",
         <<weight::lfloat, value::long, scroll::long, skill_id::long, enchantment::long>>
       ) do
    %{
      weight: weight,
      value: value,
      scroll: scroll == 1,
      skill_id: nil_if_negative(skill_id),
      enchantment: enchantment
    }
  end

  defp format_value("BOOK", "TEXT", value) do
    # 147 and 148 are Windows-specific smart quotes - replace with Unicode quotes
    # 173 is a "soft hyphen" - just delete them
    # 239 is a ï as in naïve - it works if you tell Elixir it's encoded in UTF8 but not otherwise
    value
    |> strip_null
    |> String.replace(<<147>>, "“")
    |> String.replace(<<148>>, "”")
    |> String.replace(<<173>>, "")
    |> String.replace(<<239>>, <<239::utf8>>)
  end

  defp format_value("BSGN", "TNAM", value), do: strip_null(value)

  defp format_value(
         "CELL",
         "AMBI",
         <<ambient::binary-4, sunlight::binary-4, fog_color::binary-4, density::lfloat>>
       ) do
    %{
      ambient: parse_colorref(ambient),
      sunlight: parse_colorref(sunlight),
      fog_color: parse_colorref(fog_color),
      fog_density: float(density)
    }
  end

  defp format_value("CELL", "WHGT", <<value::lfloat>>), do: value

  defp format_value("CELL", "DATA", <<flags::long, _grid_x::long, _grid_y::long>>) do
    parse_bitmask(flags,
      interior: 0x01,
      water: 0x02,
      sleep_illegal: 0x04,
      behave_like_exterior: 0x80
    )
  end

  defp format_value(
         "CELL",
         "DATA",
         <<x_pos::lfloat, y_pos::lfloat, z_pos::lfloat, x_rotate::lfloat, y_rotate::lfloat,
           z_rotate::lfloat>>
       ) do
    %{
      x_pos: float(x_pos),
      y_pos: float(y_pos),
      z_pos: float(z_pos),
      x_rotate: x_rotate,
      y_rotate: y_rotate,
      z_rotate: z_rotate
    }
  end

  defp format_value("CELL", name, <<value::long>>) when name in ["FRMR", "FLTV"], do: value
  defp format_value("CELL", "DNAM", value), do: strip_null(value)
  defp format_value("CELL", "NAM5", <<color::binary-4>>), do: parse_colorref(color)
  defp format_value("CELL", name, value) when name in ["RGNN", "ANAM"], do: strip_null(value)

  defp format_value(
         "CLAS",
         "CLDT",
         <<attribute_1::long, attribute_2::long, specialization::long, minor_1::long,
           major_1::long, minor_2::long, major_2::long, minor_3::long, major_3::long,
           minor_4::long, major_4::long, minor_5::long, major_5::long, playable::long,
           flags::long>>
       ) do
    %{
      attribute_1_id: attribute_1,
      attribute_2_id: attribute_2,
      specialization_id: specialization,
      major_skill_ids: [major_1, major_2, major_3, major_4, major_5],
      minor_skill_ids: [minor_1, minor_2, minor_3, minor_4, minor_5],
      playable: playable == 1,
      vendors:
        parse_bitmask(flags,
          weapons: 0x00001,
          armor: 0x00002,
          clothing: 0x00004,
          books: 0x00008,
          ingredients: 0x00010,
          picks: 0x00020,
          probes: 0x00040,
          lights: 0x00080,
          apparatus: 0x00100,
          repair_items: 0x00200,
          misc: 0x00400,
          spells: 0x00800,
          magic_items: 0x01000,
          potions: 0x02000
        ),
      services:
        parse_bitmask(flags,
          training: 0x04000,
          spellmaking: 0x08000,
          enchanting: 0x10000,
          repairing: 0x20000
        )
    }
  end

  defp format_value(
         "CLOT",
         "CTDT",
         <<type::long, weight::lfloat, value::short, enchantment_points::short>>
       ) do
    %{type: type, weight: float(weight), value: value, enchantment_points: enchantment_points}
  end

  defp format_value("CONT", "CNDT", <<value::lfloat>>), do: value

  defp format_value("CONT", "FLAG", <<value::long>>) do
    parse_bitmask(value, organic: 0x0001, respawns: 0x0002)
  end

  defp format_value("CONT", "NPCO", <<count::long, name::binary>>), do: {count, strip_null(name)}

  defp format_value("DIAL", "DATA", <<type::byte, _rest::binary>>), do: type
  defp format_value("DIAL", "DELE", <<type::long>>), do: type == 0

  defp format_value("ENCH", "ENDT", <<type::long, cost::long, charge::long, autocalc::long>>) do
    %{type: type, cost: cost, charge: charge, autocalc: autocalc == 1}
  end

  defp format_value("FACT", name, value) when name in ["ANAM", "RNAM"], do: strip_null(value)
  defp format_value("FACT", "INTV", <<value::long>>), do: value
  # Rankings and skills are long and repeated - split them out into their own functions
  defp format_value(
         "FACT",
         "FADT",
         <<attribute_1::long, attribute_2::long, rankings::binary-200, skills::binary-24, _::long,
           flags::long>>
       ) do
    %{
      attribute_1_id: attribute_1,
      attribute_2_id: attribute_2,
      rankings: faction_rankings(rankings),
      skill_ids: faction_skills(skills),
      flags: flags
    }
  end

  defp format_value("INFO", name, value)
       when name in ["INAM", "ONAM", "RNAM", "CNAM", "FNAM", "ANAM", "DNAM", "SNAM"] do
    strip_null(value)
  end

  defp format_value("INFO", name, value) when name in ["PNAM", "NNAM"] do
    value |> strip_null |> nil_if_empty
  end

  defp format_value("INFO", name, <<value::8>>) when name in ["QSTN", "QSTF", "QSTR"], do: value

  defp format_value(
         "INFO",
         "SCVR",
         <<_index::binary-1, type::binary-1, function::binary-2, operator::binary-1,
           name::binary>>
       ) do
    %{type: type, function: function, operator: operator, name: name}
  end

  defp format_value("INFO", "INTV", <<value::long>>), do: value
  defp format_value("INFO", "FLTV", <<value::lfloat>>), do: value

  # Data is different for journal entries and dialogue responses
  defp format_value("INFO", "DATA", <<4::long, index::long, 255, 255, 255, 0>>), do: index

  defp format_value(
         "INFO",
         "DATA",
         <<_unknown1::long, disposition::long, npc_rank::byte, gender::8, pc_rank::byte,
           _unknown2::8>>
       ) do
    %{
      disposition: disposition,
      npc_rank: nil_if_negative(npc_rank),
      pc_rank: nil_if_negative(pc_rank),
      gender: parse_gender(gender)
    }
  end

  defp format_value(
         "INGR",
         "IRDT",
         <<weight::lfloat, value::long, effects::binary-16, skills::binary-16,
           attributes::binary-16>>
       ) do
    %{
      weight: float(weight),
      value: value,
      ingredient_effects: zip_ingredient_effects(effects, skills, attributes)
    }
  end

  defp format_value("LEVI", "DATA", <<value::long>>) do
    parse_bitmask(value, calculate_for_each_item: 1, calculate_for_all_levels: 2)
  end

  defp format_value("LEVI", "NNAM", <<value::byte>>), do: value
  defp format_value("LEVI", "INAM", value), do: strip_null(value)
  defp format_value("LEVI", "INTV", <<value::short>>), do: value

  defp format_value("LOCK", "LKDT", <<weight::lfloat, value::long, quality::lfloat, uses::long>>) do
    %{weight: float(weight), value: value, quality: float(quality), uses: uses}
  end

  defp format_value("MGEF", name, value)
       when name in ["AVFX", "BVFX", "HVFX", "CVFX", "ASND", "BSND", "HSND", "CSND"] do
    strip_null(value)
  end

  defp format_value(
         "MGEF",
         "MEDT",
         <<school::long, base_cost::lfloat, flags::long, red::long, green::long, blue::long,
           speed::lfloat, size::lfloat, size_cap::lfloat>>
       ) do
    %{
      school: school,
      base_cost: float(base_cost),
      color: parse_colorref({red, green, blue}),
      speed: float(speed),
      size: float(size),
      size_cap: float(size_cap)
    }
    |> Map.merge(parse_bitmask(flags, spellmaking: 0x0200, enchanting: 0x0400, negative: 0x0800))
  end

  defp format_value("MISC", "MCDT", <<weight::lfloat, value::long, _::binary>>) do
    %{weight: float(weight), value: value}
  end

  defp format_value(
         "NPC_",
         "AIDT",
         <<hello::byte, _::byte, fight::byte, flee::byte, alarm::byte, _::byte, _::byte, _::byte,
           flags::long>>
       ) do
    %{
      hello: hello,
      fight: fight,
      flee: flee,
      alarm: alarm,
      flags:
        parse_bitmask(flags,
          weapon: 0x00001,
          armor: 0x00002,
          clothing: 0x00004,
          books: 0x00008,
          ingredients: 0x00010,
          picks: 0x00020,
          probes: 0x00040,
          lights: 0x00080,
          apparatus: 0x00100,
          repair: 0x00200,
          misc: 0x00400,
          spells: 0x00800,
          magic_items: 0x01000,
          potions: 0x02000,
          training: 0x04000,
          spellmaking: 0x08000,
          enchanting: 0x10000,
          repair_item: 0x20000
        )
    }
  end

  defp format_value("NPC_", name, <<value::binary>>)
       when name in ["ANAM", "BNAM", "RNAM", "KNAM"] do
    value |> strip_null |> nil_if_empty
  end

  defp format_value("NPC_", "CNAM", <<value::binary>>), do: value |> strip_null

  defp format_value("NPC_", "FLAG", <<value::long>>) do
    parse_bitmask(value,
      female: 0x0001,
      essential: 0x0002,
      respawn: 0x0004,
      autocalc: 0x0010,
      skeleton_blood: 0x0400,
      metal_blood: 0x0800
    )
  end

  defp format_value("NPC_", "NPCO", <<count::long, name::binary>>), do: {count, strip_null(name)}

  defp format_value(
         "NPC_",
         "NPDT",
         <<level::short, disposition::byte, _faction_id::byte, rank::byte, _::byte, _::byte,
           _::byte, gold::long>>
       ) do
    %{level: level, disposition: disposition, rank: rank, gold: gold}
  end

  defp format_value(
         "NPC_",
         "NPDT",
         <<level::short, str::byte, int::byte, wil::byte, agi::byte, spd::byte, endr::byte,
           per::byte, luk::byte, skills::binary-27, reputation::byte, health::short,
           magicka::short, fatigue::short, disposition::byte, _faction_id::byte, rank::byte,
           _::byte, gold::long>>
       ) do
    %{
      level: level,
      attributes: %{
        0 => str,
        1 => int,
        2 => wil,
        3 => agi,
        4 => spd,
        5 => endr,
        6 => per,
        7 => luk
      },
      skills: parse_npc_skills(skills),
      reputation: reputation,
      health: health,
      magicka: magicka,
      fatigue: fatigue,
      disposition: disposition,
      rank: rank,
      gold: gold
    }
  end

  # Exactly the same as "LOCK"/"LKDT".
  defp format_value("PROB", "PBDT", <<weight::lfloat, value::long, quality::lfloat, uses::long>>) do
    %{weight: float(weight), value: value, quality: float(quality), uses: uses}
  end

  defp format_value(
         "RACE",
         "RADT",
         <<skills::binary-56, str_m::long, str_f::long, int_m::long, int_f::long, wil_m::long,
           wil_f::long, agi_m::long, agi_f::long, spd_m::long, spd_f::long, end_m::long,
           end_f::long, per_m::long, per_f::long, luc_m::long, luc_f::long, height_m::lfloat,
           height_f::lfloat, weight_m::lfloat, weight_f::lfloat, flags::long>>
       ) do
    %{
      skill_bonuses: race_skills(skills),
      male_attributes: %{
        str: str_m,
        int: int_m,
        wil: wil_m,
        agi: agi_m,
        spd: spd_m,
        end: end_m,
        per: per_m,
        luc: luc_m,
        height: float(height_m),
        weight: float(weight_m)
      },
      female_attributes: %{
        str: str_f,
        int: int_f,
        wil: wil_f,
        agi: agi_f,
        spd: spd_f,
        end: end_f,
        per: per_f,
        luc: luc_f,
        height: float(height_f),
        weight: float(weight_f)
      }
    }
    |> Map.merge(parse_bitmask(flags, playable: 1, beast: 2))
  end

  defp format_value("REGN", "CNAM", <<red::integer, green::integer, blue::integer, _::integer>>) do
    parse_colorref({red, green, blue})
  end

  defp format_value(
         "REGN",
         "WEAT",
         <<clear::integer, cloudy::integer, foggy::integer, overcast::integer, rain::integer,
           thunder::integer, ash::integer, blight::integer>>
       ) do
    %{
      clear: clear,
      cloudy: cloudy,
      foggy: foggy,
      overcast: overcast,
      rain: rain,
      thunder: thunder,
      ash: ash,
      blight: blight,
      snow: 0,
      blizzard: 0
    }
  end

  defp format_value(
         "REGN",
         "WEAT",
         <<clear::integer, cloudy::integer, foggy::integer, overcast::integer, rain::integer,
           thunder::integer, ash::integer, blight::integer, snow::integer, blizzard::integer>>
       ) do
    %{
      clear: clear,
      cloudy: cloudy,
      foggy: foggy,
      overcast: overcast,
      rain: rain,
      thunder: thunder,
      ash: ash,
      blight: blight,
      snow: snow,
      blizzard: blizzard
    }
  end

  # Just _slightly_ different than "LOCK"/"LKDT" and "PROB"/"PBDT".
  defp format_value("REPA", "RIDT", <<weight::lfloat, value::long, uses::long, quality::lfloat>>) do
    %{weight: float(weight), value: value, quality: float(quality), uses: uses}
  end

  defp format_value("SCPT", "SCHD", <<name::binary-32, _rest::binary>>) do
    %{name: strip_null(name)}
  end

  defp format_value("SCPT", "SCTX", value) do
    value
    # Smart single quote
    |> String.replace(<<146>>, "’")
  end

  defp format_value("SPEL", "SPDT", <<type::long, cost::long, flags::long>>) do
    # flags is a bitmask - 1 = autocalc, 2 = starting spell, 4 = always succeeds
    %{type: type, cost: cost}
    |> Map.merge(parse_bitmask(flags, autocalc: 1, starting_spell: 2, always_succeeds: 4))
  end

  defp format_value("SKIL", "SKDT", <<attribute_id::long, specialization::long, uses::binary>>) do
    %{attribute_id: attribute_id, specialization_id: specialization, uses: uses}
  end

  defp format_value(
         name,
         "ENAM",
         <<effect::short, skill::byte, attribute::byte, type::long, area::long, duration::long,
           min::long, max::long>>
       )
       when name in ["ALCH", "SPEL", "ENCH"] do
    %{
      magic_effect_id: effect,
      skill_id: nil_if_negative(skill),
      attribute_id: nil_if_negative(attribute),
      type: type,
      area: area,
      duration: duration,
      magnitude_min: min,
      magnitude_max: max
    }
  end

  defp format_value(
         "TES3",
         "HEDR",
         <<version::lfloat, _::long, company::binary-32, description::binary-256, _::binary>>
       ) do
    %{
      version: Float.round(version, 2),
      company: strip_null(company),
      description: strip_null(description)
    }
  end

  defp format_value("TES3", "DATA", <<value::long64>>), do: value

  defp format_value(
         "WEAP",
         "WPDT",
         <<weight::lfloat, value::long, type::short, health::short, speed::lfloat, reach::lfloat,
           enchantment_points::short, chop_min::byte, chop_max::byte, slash_min::byte,
           slash_max::byte, thrust_min::byte, thrust_max::byte, flags::long>>
       ) do
    %{
      weight: weight,
      value: value,
      type: type,
      health: health,
      speed: float(speed),
      reach: reach,
      enchantment_points: enchantment_points,
      chop_min: chop_min,
      chop_max: chop_max,
      slash_min: slash_min,
      slash_max: slash_max,
      thrust_min: thrust_min,
      thrust_max: thrust_max
    }
    |> Map.merge(parse_bitmask(flags, ignore_resistance: 1, silver: 2))
  end

  defp format_value(_type, _name, value), do: value

  ###############################
  # Misc. helper methods
  ###############################

  defp strip_null(name), do: name |> String.split(<<0>>, parts: 2) |> List.first()

  defp record_pair_key(list, key, value) do
    Map.update(list, key, [{value, nil}], &[{value, nil} | &1])
  end

  defp record_pair_value(list, key, value) do
    Map.update!(list, key, fn [{key, nil} | rest] -> rest ++ [{key, value}] end)
  end

  defp record_list(list, key, value) do
    Map.update(list, key, [value], &(&1 ++ [value]))
  end

  defp record_list_map_key(list, field, key, value) do
    Map.update(list, field, [%{key => value}], &[%{key => value} | &1])
  end

  defp record_list_map_value(list, field, key, value) do
    Map.update!(list, field, fn [map | rest] -> [Map.put(map, key, value) | rest] end)
  end

  defp parse_bitmask(mask, list), do: parse_bitmask(mask, list, %{})
  defp parse_bitmask(_mask, [], map), do: map

  defp parse_bitmask(mask, [{key, value} | rest], map) do
    map = Map.put(map, key, band(mask, value) == value)
    parse_bitmask(mask, rest, map)
  end

  defp parse_colorref(<<red::integer-8, green::integer-8, blue::integer-8, _rest>>) do
    parse_colorref({red, green, blue})
  end

  defp parse_colorref({red, green, blue}), do: "#" <> Base.encode16(<<red, green, blue>>)

  defp parse_npc_skills(skills), do: parse_npc_skills(skills, %{}, 0)
  defp parse_npc_skills("", skills, _), do: skills

  defp parse_npc_skills(<<value::byte, rest::binary>>, skills, count) do
    parse_npc_skills(rest, Map.put(skills, count, value), count + 1)
  end

  defp nil_if_empty(value) when value == "", do: nil
  defp nil_if_empty(value), do: value

  defp nil_if_negative(value) when value < 0, do: nil
  defp nil_if_negative(value), do: value

  defp faction_skills(skills), do: faction_skills(skills, [])
  defp faction_skills("", list), do: Enum.reverse(list)
  defp faction_skills(<<-1::long, _rest::binary>>, list), do: list

  defp faction_skills(<<skill::long, rest::binary>>, list) do
    faction_skills(rest, [skill | list])
  end

  defp faction_rankings(rankings), do: faction_rankings(rankings, [], 1)
  defp faction_rankings("", list, _number), do: Enum.reverse(list)

  defp faction_rankings(
         <<attribute_1::long, attribute_2::long, skill_1::long, skill_2::long, reputation::long,
           rest::binary>>,
         list,
         number
       ) do
    faction_rankings(
      rest,
      [
        %{
          number: number,
          attribute_1: attribute_1,
          attribute_2: attribute_2,
          skill_1: skill_1,
          skill_2: skill_2,
          reputation: reputation
        }
        | list
      ],
      number + 1
    )
  end

  defp race_skills(skills), do: race_skills(skills, [])
  defp race_skills("", list), do: list
  defp race_skills(<<-1::long, _rest::binary>>, list), do: list

  defp race_skills(<<skill::long, bonus::long, rest::binary>>, list) do
    race_skills(rest, [%{skill_id: skill, bonus: bonus} | list])
  end

  defp zip_ingredient_effects(effects, skills, attributes) do
    zip_ingredient_effects(effects, skills, attributes, [])
  end

  defp zip_ingredient_effects("", "", "", parsed), do: Enum.reverse(parsed)
  defp zip_ingredient_effects(<<-1::long, _rest::binary>>, _, _, parsed), do: Enum.reverse(parsed)

  defp zip_ingredient_effects(
         <<effect::long, effects::binary>>,
         <<skill::long, skills::binary>>,
         <<attribute::long, attributes::binary>>,
         parsed
       ) do
    parsed_effect = %{
      magic_effect_id: effect,
      skill_id: nil_if_negative(skill),
      attribute_id: nil_if_negative(attribute)
    }

    zip_ingredient_effects(effects, skills, attributes, [parsed_effect | parsed])
  end

  defp float(val), do: Float.round(val, 2)

  defp parse_gender(0xFF), do: nil
  defp parse_gender(0x00), do: :male
  defp parse_gender(0x01), do: :female
end
