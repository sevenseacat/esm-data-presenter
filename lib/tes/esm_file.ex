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
  defp record_value(list, "FACT", "RNAM", value), do: record_list(list, "RNAM", value)

  defp record_value(list, "FACT", "ANAM", value), do: record_pair_key(list, "ANAM/INTV", value)
  defp record_value(list, "FACT", "INTV", value), do: record_pair_value(list, "ANAM/INTV", value)

  defp record_value(list, "BSGN", "NPCS", value), do: record_list(list, "NPCS", value)
  defp record_value(list, "SPEL", "ENAM", value), do: record_list(list, "ENAM", value)

  defp record_value(list, _type, name, value), do: Map.put_new(list, name, value)

  ###############################
  # For field-specific formatting.
  # eg. some fields are null-terminated strings, some are bitmasks, some are little-endian integers
  ###############################
  defp format_value(_type, name, value) when name in ["NAME", "FNAM", "DESC"], do: strip_null(value)
  defp format_value(_type, "INDX", <<id::long>>), do: id
  # These are filenames that for some reason have double directory separators in them
  defp format_value(_type, name, value) when name in ["MODL", "ITEX", "PTEX"] do
    value |> strip_null |> String.replace("\\\\", "\\")
  end

  defp format_value("SPEL", "SPDT", <<type::long, cost::long, flags::long>>) do
    # flags is a bitmask - 1 = autocalc, 2 = starting spell, 4 = always succeeds
    %{type: type, cost: cost, autocalc: band(flags, 1) == 1,
      starting_spell: band(flags, 2) == 2, always_succeeds: band(flags, 4) == 4}
  end

  defp format_value("SPEL", "ENAM", <<effect::signed-little-16, skill::signed-little-8,
    attribute::signed-little-8, type::long, area::long, duration::long, min::long, max::long>>) do
    %{effect_id: effect, skill_id: nil_or_value(skill), attribute_id: nil_or_value(attribute),
      type: type, area: area, duration: duration, magnitude_min: min, magnitude_max: max}
  end

  defp format_value("MGEF", name, value) when name in ["AVFX", "BVFX", "HVFX", "CVFX", "ASND",
    "BSND", "HSND", "CSND"] do
    strip_null(value)
  end
  defp format_value("MGEF", "MEDT", <<school::long, base_cost::little-float-32, flags::long,
    red::long, green::long, blue::long, speed::little-float-32, size::little-float-32,
    size_cap::little-float-32>>) do
    %{school: school, base_cost: base_cost, spellmaking: band(flags, 0x0200) == 0x0200,
      enchanting: band(flags, 0x0400) == 0x0400, negative: band(flags, 0x0800) == 0x0800, red: red,
      blue: blue, green: green, speed: speed, size: size, size_cap: size_cap}
  end

  defp format_value("BSGN", name, value) when name in ["TNAM", "NPCS"], do: strip_null(value)

  defp format_value("FACT", name, value) when name in ["ANAM", "RNAM"], do: strip_null(value)
  defp format_value("FACT", "INTV", <<value::long>>), do: value
  # Rankings and skills are long and repeated - split them out into their own functions
  defp format_value("FACT", "FADT", <<attribute_1::long, attribute_2::long,
    rankings::binary-200, skills::binary-24, unknown::long, flags::long>>) do
    %{attribute_ids: [attribute_1, attribute_2], rankings: faction_rankings(rankings),
      skill_ids: faction_skills(skills), unknown: unknown, flags: flags}
  end

  defp format_value("BOOK", name, value) when name in ["SCRI", "ENAM"], do: strip_null(value)
  defp format_value("BOOK", "BKDT", <<weight::little-float-32, value::long, scroll::long,
    skill_id::long, enchantment::long>>) do
    %{weight: weight, value: value, scroll: scroll == 1, skill_id: nil_or_value(skill_id),
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

  defp format_value("SKIL", "SKDT", <<attribute_id::long, specialization::long, uses::binary>>) do
    %{attribute_id: attribute_id, specialization_id: specialization, uses: uses}
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

  defp nil_or_value(value), do: if value >= 0, do: value, else: nil

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
end
