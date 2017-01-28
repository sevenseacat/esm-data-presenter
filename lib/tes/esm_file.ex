defmodule Tes.EsmFile do
  import Bitwise, only: [band: 2]
  alias Tes.EsmFormatter

  @default_file "data/Morrowind.esm"

  defmacro long do
    quote do: signed-little-integer-size(32)
  end

  @doc """
  iex> Tes.EsmFile.stream("data/Morrowind.esm") |> Stream.run
  [{:book, %{...}}, {:weapon, %{...}}, ...]
  """
  def stream(filename \\ @default_file) do
    Stream.resource(
      fn -> File.open!(filename, [:binary]) end,
      fn(file) -> next_record(file) end,
      fn(file) -> File.close(file) end
    )
  end

  # The ESM/ESP/ESS files are composed entirely of records with the following format:
  #
  # 4 bytes: char Name[4]
  #    4-byte record name string (not null-terminated)
  # 4 bytes: long Size
  #   Size of the record not including the 16 bytes of header data.
  # 4 bytes: long Header1
  # 4 bytes: long Flags
  # ? bytes: SubRecords[]
  #   All records are composed of a variable number of sub-records. There
  #   is no sub-record count, just use the record Size value to determine
  #   when to stop reading a record.
  #
  # File format taken from http://www.uesp.net/morrow/tech/mw_esm.txt
  defp next_record(file) do
    case IO.binread(file, 16) do
      :eof -> {:halt, file}
      <<type::binary-4, size::long, _header1::bytes-4, _flags::bytes-4>> ->
        subrecords = file |> IO.binread(size) |> parse_sub_records(type, %{})
        {[EsmFormatter.build_record(type, subrecords)], file}
    end
  end

  # All records, as shown above, are again composed entirely of a variable number of
  # sub-records with a similar format, as given below:
  #
  # 4 bytes: char Name[4]
  #   4-byte sub-record name string (not null-terminated)
  # 4 bytes: long Size
  #   Size of the sub-record not including the 8 bytes of header data.
  # ? bytes: Sub-Record data.
  #   Format depends on the sub-record type (see below).
  #
  # File format taken from http://www.uesp.net/morrow/tech/mw_esm.txt
  defp parse_sub_records("", _type, list), do: list
  defp parse_sub_records(<<name::binary-4, size::long, rest::binary>>, type, list) do
    # Split the "rest" out into the content for this sub-record, and the rest
    value = binary_part(rest, 0, size)
    rest = binary_part(rest, size, (byte_size(rest) - size))

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
  defp record_value(list, "CELL", name, value) when name in ["XSCL", "DELE", "DODT", "DNAM",
    "FLTV", "KNAM", "TNAM", "UNAM", "ANAM", "BNAM", "NAM9", "XSOL", "DATA"] do
    record_list_map_value(list, "REFS", name, value)
  end

  defp record_value(list, "ENCH", "ENAM", value), do: record_list(list, "ENAM", value)

  defp record_value(list, "FACT", "RNAM", value), do: record_list(list, "RNAM", value)

  defp record_value(list, "FACT", "ANAM", value), do: record_pair_key(list, "ANAM/INTV", value)
  defp record_value(list, "FACT", "INTV", value), do: record_pair_value(list, "ANAM/INTV", value)

  defp record_value(list, "INFO", "SCVR", value), do: record_pair_key(list, "CONDS", value)
  defp record_value(list, "INFO", "INTV", value), do: record_pair_value(list, "CONDS", value)
  defp record_value(list, "INFO", "FLTV", value), do: record_pair_value(list, "CONDS", value)

  defp record_value(list, _type, "NPCS", value), do: record_list(list, "NPCS", value)
  defp record_value(list, "SPEL", "ENAM", value), do: record_list(list, "ENAM", value)

  defp record_value(list, _type, name, value), do: Map.put_new(list, name, value)

  ###############################
  # For field-specific formatting.
  # eg. some fields are null-terminated strings, some are bitmasks, some are little-endian integers
  ###############################

  defp format_value(_type, name, value) when name in ["NAME", "FNAM", "DESC", "NPCS"] do
    strip_null(value)
  end
  defp format_value(_type, "INDX", <<id::long>>), do: id
  # These are filenames that for some reason have double directory separators in them
  defp format_value(_type, name, value) when name in ["MODL", "ITEX", "PTEX"] do
    value |> strip_null
  end

  defp format_value("APPA", "AADT", <<type::long, quality::signed-little-float-32,
    weight::signed-little-float-32, value::long>>) do
    %{type: type, weight: float(weight), value: value, quality: float(quality)}
  end
  defp format_value("APPA", "SCRI", value), do: strip_null(value)

  defp format_value("BOOK", name, value) when name in ["SCRI", "ENAM"], do: strip_null(value)
  defp format_value("BOOK", "BKDT", <<weight::little-float-32, value::long, scroll::long,
    skill_id::long, enchantment::long>>) do
    %{weight: weight, value: value, scroll: scroll == 1, skill_id: nil_if_negative(skill_id),
      enchantment: enchantment}
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

  defp format_value("CELL", "AMBI", <<ambient::binary-4, sunlight::binary-4, fog_color::binary-4,
    density::signed-little-float-32>>) do
    %{ambient: parse_colorref(ambient), sunlight: parse_colorref(sunlight),
      fog: parse_colorref(fog_color) |> Map.put(:density, float(density))}
  end
  defp format_value("CELL", "WHGT", <<value::signed-little-float-32>>), do: value
  defp format_value("CELL", "DATA", <<flags::long, _grid_x::long, _grid_y::long>>) do
    parse_bitmask(flags, [interior: 0x01, water: 0x02, sleep_illegal: 0x04,
      behave_like_exterior: 0x80])
  end
  defp format_value("CELL", "DATA", <<x_pos::signed-little-float-32, y_pos::signed-little-float-32,
    z_pos::signed-little-float-32, x_rotate::signed-little-float-32,
    y_rotate::signed-little-float-32, z_rotate::signed-little-float-32>>) do
    %{x_pos: float(x_pos), y_pos: float(y_pos), z_pos: float(z_pos), x_rotate: x_rotate,
      y_rotate: y_rotate, z_rotate: z_rotate}
  end
  defp format_value("CELL", "FRMR", <<value::long>>), do: value
  defp format_value("CELL", "NAM5", <<color::binary-4>>), do: parse_colorref(color)
  defp format_value("CELL", name, value) when name in ["RGNN", "ANAM"], do: strip_null(value)

  defp format_value("CLAS", "CLDT", <<attribute_1::long, attribute_2::long, specialization::long,
    minor_1::long, major_1::long, minor_2::long, major_2::long, minor_3::long, major_3::long,
    minor_4::long, major_4::long, minor_5::long, major_5::long, playable::long, flags::long>>) do
    %{attributes: [attribute_1, attribute_2], specialization: specialization,
      major_skills: [major_1, major_2, major_3, major_4, major_5],
      minor_skills: [minor_1, minor_2, minor_3, minor_4, minor_5], playable: playable == 1,
      autocalc: parse_bitmask(flags, [weapon: 0x00001, armor: 0x00002, clothing: 0x00004,
        book: 0x00008, ingredient: 0x00010, pick: 0x00020, probe: 0x00040, light: 0x00080,
        apparatus: 0x00100, repair: 0x00200, misc: 0x00400, spell: 0x00800, magic_item: 0x01000,
        potion: 0x02000, training: 0x04000, spellmaking: 0x08000, enchanting: 0x10000,
        repair_item: 0x20000])}
  end

  defp format_value("DIAL", "DATA", <<type::integer-8, _rest::binary>>), do: type
  defp format_value("DIAL", "DELE", <<type::long>>), do: type == 0

  defp format_value("ENCH", "ENDT", <<type::long, cost::long, charge::long, autocalc::long>>) do
    %{type: type, cost: cost, charge: charge, autocalc: autocalc == 1}
  end
  defp format_value("FACT", name, value) when name in ["ANAM", "RNAM"], do: strip_null(value)
  defp format_value("FACT", "INTV", <<value::long>>), do: value
  # Rankings and skills are long and repeated - split them out into their own functions
  defp format_value("FACT", "FADT", <<attribute_1::long, attribute_2::long,
    rankings::binary-200, skills::binary-24, unknown::long, flags::long>>) do
    %{attribute_ids: [attribute_1, attribute_2], rankings: faction_rankings(rankings),
      skill_ids: faction_skills(skills), unknown: unknown, flags: flags}
  end

  defp format_value("INFO", name, value) when name in ["INAM", "ONAM", "RNAM", "CNAM", "FNAM",
    "ANAM", "DNAM", "SNAM"] do
    strip_null(value)
  end
  defp format_value("INFO", name, value) when name in ["PNAM", "NNAM"] do
    value |> strip_null |> nil_if_empty
  end
  defp format_value("INFO", name, <<value::8>>) when name in ["QSTN", "QSTF", "QSTR"], do: value
  defp format_value("INFO", "SCVR", <<index::binary-1, type::binary-1, function::binary-2,
    operator::binary-1, name::binary>>) do
    %{index: index, type: type, function: function, operator: operator, name: name}
  end
  defp format_value("INFO", "INTV", <<value::long>>), do: value
  defp format_value("INFO", "FLTV", <<value::signed-little-float-32>>), do: value

  # Data is different for journal entries and dialogue responses
  defp format_value("INFO", "DATA", <<4::long, index::long, 255, 255, 255, 0>>), do: index
  defp format_value("INFO", "DATA", <<_unknown1::long, disposition::long, npc_rank::signed-8,
    gender::8, pc_rank::signed-8, _unknown2::8>>) do
    %{disposition: disposition, npc_rank: nil_if_negative(npc_rank),
      pc_rank: nil_if_negative(pc_rank), gender: parse_gender(gender)}
  end

  defp format_value("INGR", "IRDT", <<weight::little-float-32, value::long, effects::binary-16,
    skills::binary-16, attributes::binary-16>>) do
    %{weight: float(weight), value: value,
      effects: zip_ingredient_effects(effects, skills, attributes)}
  end

  defp format_value("LOCK", "LKDT", <<weight::signed-little-float-32, value::long,
    quality::signed-little-float-32, uses::long>>) do
    %{weight: float(weight), value: value, quality: float(quality), uses: uses}
  end

  defp format_value("MGEF", name, value) when name in ["AVFX", "BVFX", "HVFX", "CVFX", "ASND",
    "BSND", "HSND", "CSND"] do
    strip_null(value)
  end
  defp format_value("MGEF", "MEDT", <<school::long, base_cost::little-float-32, flags::long,
    red::long, green::long, blue::long, speed::little-float-32, size::little-float-32,
    size_cap::little-float-32>>) do
    %{school: school, base_cost: float(base_cost), red: red, blue: blue, green: green,
      speed: float(speed), size: float(size), size_cap: float(size_cap)}
    |> Map.merge(parse_bitmask(flags, [spellmaking: 0x0200, enchanting: 0x0400, negative: 0x0800]))
  end

  defp format_value("MISC", "MCDT", <<weight::signed-little-float-32, value::long, _::binary>>) do
    %{weight: float(weight), value: value}
  end

  # Exactly the same as "LOCK"/"LKDT".
  defp format_value("PROB", "PBDT", <<weight::signed-little-float-32, value::long,
    quality::signed-little-float-32, uses::long>>) do
    %{weight: float(weight), value: value, quality: float(quality), uses: uses}
  end

  defp format_value("RACE", "RADT", <<skills::binary-56, str_m::long, str_f::long, int_m::long,
    int_f::long, wil_m::long, wil_f::long, agi_m::long, agi_f::long, spd_m::long, spd_f::long,
    end_m::long, end_f::long, per_m::long, per_f::long, luc_m::long, luc_f::long,
    height_m::little-float-32, height_f::little-float-32, weight_m::little-float-32,
    weight_f::little-float-32, flags::long>>) do
    %{skill_bonuses: race_skills(skills),
      male_attributes: %{str: str_m, int: int_m, wil: wil_m, agi: agi_m, spd: spd_m, end: end_m,
        per: per_m, luc: luc_m, height: Float.round(height_m, 2), weight: Float.round(weight_m, 2)},
      female_attributes: %{str: str_f, int: int_f, wil: wil_f, agi: agi_f, spd: spd_f, end: end_f,
        per: per_f, luc: luc_f, height: Float.round(height_f, 2), weight: Float.round(weight_f, 2)}}
    |> Map.merge(parse_bitmask(flags, [playable: 1, beast: 2]))
  end

  defp format_value("REGN", "CNAM", <<red::integer, green::integer, blue::integer, _::integer>>) do
    %{red: red, green: green, blue: blue}
  end

  defp format_value("REGN", "WEAT", <<clear::integer, cloudy::integer, foggy::integer,
    overcast::integer, rain::integer, thunder::integer, ash::integer, blight::integer,
    snow::integer, blizzard::integer>>) do
    %{clear: clear, cloudy: cloudy, foggy: foggy, overcast: overcast, rain: rain, thunder: thunder,
      ash: ash, blight: blight, snow: snow, blizzard: blizzard}
  end

  # Just _slightly_ different than "LOCK"/"LKDT" and "PROB"/"PBDT".
  defp format_value("REPA", "RIDT", <<weight::signed-little-float-32, value::long,
    uses::long, quality::signed-little-float-32>>) do
    %{weight: float(weight), value: value, quality: float(quality), uses: uses}
  end


  defp format_value("SCPT", "SCHD", <<name::binary-32, _rest::binary>>) do
    %{name: strip_null(name)}
  end

  defp format_value("SPEL", "SPDT", <<type::long, cost::long, flags::long>>) do
    # flags is a bitmask - 1 = autocalc, 2 = starting spell, 4 = always succeeds
    %{type: type, cost: cost}
    |> Map.merge(parse_bitmask(flags, [autocalc: 1, starting_spell: 2, always_succeeds: 4]))
  end

  defp format_value("SKIL", "SKDT", <<attribute_id::long, specialization::long, uses::binary>>) do
    %{attribute_id: attribute_id, specialization_id: specialization, uses: uses}
  end

  defp format_value(name, "ENAM", <<effect::signed-little-16, skill::signed-little-8,
    attribute::signed-little-8, type::long, area::long, duration::long, min::long, max::long>>)
    when name in ["SPEL", "ENCH"] do
    %{effect_id: effect, skill_id: nil_if_negative(skill), attribute_id: nil_if_negative(attribute),
      type: type, area: area, duration: duration, magnitude_min: min, magnitude_max: max}
  end

  defp format_value(_type, _name, value), do: value

  ###############################
  # Misc. helper methods
  ###############################

  defp strip_null(name), do: name |> String.split(<<0>>, parts: 2) |> List.first

  defp record_pair_key(list, key, value) do
    Map.update(list, key, [{value, nil}], &([{value, nil} | &1]))
  end

  defp record_pair_value(list, key, value) do
    Map.update!(list, key, fn([{key, nil} | rest]) -> [{key, value} | rest] end)
  end

  defp record_list(list, key, value) do
    Map.update(list, key, [value], &(&1 ++ [value]))
  end

  defp record_list_map_key(list, field, key, value) do
    Map.update(list, field, [%{key => value}], &([%{key => value} | &1]))
  end

  defp record_list_map_value(list, field, key, value) do
    Map.update!(list, field, fn([map | rest]) -> [Map.put(map, key, value) | rest] end)
  end

  defp parse_bitmask(mask, list), do: parse_bitmask(mask, list, %{})
  defp parse_bitmask(_mask, [], map), do: map
  defp parse_bitmask(mask, [{key, value} | rest], map) do
    map = Map.put(map, key, band(mask, value) == value)
    parse_bitmask(mask, rest, map)
  end

  defp parse_colorref(<<red::integer-8, green::integer-8, blue::integer-8, _rest>>) do
    %{red: red, green: green, blue: blue}
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
  defp faction_rankings(<<attribute_1::long, attribute_2::long, skill_1::long, skill_2::long,
    reputation::long, rest::binary>>, list, number) do
    faction_rankings(rest, [%{number: number, attribute_1: attribute_1, attribute_2: attribute_2,
      skill_1: skill_1, skill_2: skill_2, reputation: reputation} | list], number + 1)
  end

  defp race_skills(skills), do: race_skills(skills, [])
  defp race_skills("", list), do: list
  defp race_skills(<<-1::long, _rest::binary>>, list), do: list
  defp race_skills(<<skill::long, bonus::long, rest::binary>>, list) do
    race_skills(rest, [%{skill_id: skill, bonus: bonus} | list])
  end

  def zip_ingredient_effects(effects, skills, attributes) do
    zip_ingredient_effects(effects, skills, attributes, [])
  end
  def zip_ingredient_effects("", "", "", parsed), do: Enum.reverse(parsed)
  def zip_ingredient_effects(<<-1::long, _rest::binary>>, _, _, parsed), do: Enum.reverse(parsed)
  def zip_ingredient_effects(<<effect::long, effects::binary>>, <<skill::long, skills::binary>>,
    <<attribute::long, attributes::binary>>, parsed) do
    parsed_effect = %{effect_id: effect, skill_id: nil_if_negative(skill),
      attribute_id: nil_if_negative(attribute)}
    zip_ingredient_effects(effects, skills, attributes, [parsed_effect | parsed])
  end

  defp float(val), do: Float.round(val, 2)

  defp parse_gender(0xFF), do: nil
  defp parse_gender(0x00), do: :male
  defp parse_gender(0x01), do: :female
end
