defmodule Tes.EsmFile do
  @default_file "data/Morrowind.esm"

  @doc """
  Example:

  iex> Tes.EsmFile.stream("data/Morrowind.esm") |> Stream.run
  [%Tes.Book{...}, %Tes.Weapon{...}, ...]
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
  #   Unknown value, usually 0 (deleted/ignored flag?).
  # 4 bytes: long Flags
  #   Record flags.
  #      0x00002000 = Blocked
  #      0x00000400 = Persistant
  # ? bytes: SubRecords[]
  #   All records are composed of a variable number of sub-records. There
  #   is no sub-record count, just use the record Size value to determine
  #   when to stop reading a record.
  #
  # File format taken from http://www.uesp.net/morrow/tech/mw_esm.txt
  defp next_record(file) do
    case IO.binread(file, 16) do
      :eof -> {:halt, file}
      <<type::binary-size(4), size::little-integer-size(32), _header1::bytes-size(4), _flags::bytes-size(4)>> ->
        subrecords = IO.binread(file, size) |> parse_sub_records(type, %{})
        {[Tes.EsmFormatter.build_record(type, subrecords)], file}
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
  defp parse_sub_records(<<name::binary-size(4), size::little-integer-size(32), rest::binary>>, type, list) do
    # Split the "rest" out into the content for this sub-record, and the rest
    value = binary_part(rest, 0, size)
    rest = binary_part(rest, size, (byte_size(rest)-size))

    new_list = record_value(list, type, name, format_value(type, name, value))
    parse_sub_records(rest, type, new_list)
  end

  defp record_value(list, "FACT", "RNAM", value), do: record_list(list, "RNAM", value)

  # ANAM and INTV subrecords come in pairs and should be stored together
  defp record_value(list, "FACT", "ANAM", value), do: record_pair_key(list, "ANAM/INTV", value)
  defp record_value(list, "FACT", "INTV", value), do: record_pair_value(list, "ANAM/INTV", value)

  # ANAM and INTV subrecords come in pairs and should be stored together
  defp record_value(list, "BSGN", "NPCS", value), do: record_list(list, "NPCS", value)

  defp record_value(list, _type, name, value), do: Map.put_new(list, name, value)

  # For type-specific formatting.
  # eg. some fields are null-terminated strings, some are bitmasks, some are little-endian integers

  defp format_value("BSGN", name, value) when name in ["DESC", "NAME", "FNAM", "TNAM", "NPCS"], do: strip_null(value)

  defp format_value("FACT", name, value) when name in ["FNAM", "NAME", "RNAM", "ANAM"], do: strip_null(value)
  defp format_value("FACT", "INTV", <<value::signed-little-integer-size(32)>>), do: value
  # Rankings and skills are long and repeated - split them out into their own functions
  defp format_value("FACT", "FADT", <<
    attribute_1::little-integer-size(32), attribute_2::little-integer-size(32),
    rankings::binary-size(200), skills::binary-size(24),
    unknown::little-integer-size(32), flags::signed-little-integer-size(32)>>) do
      %{attribute_ids: [attribute_1, attribute_2], rankings: faction_rankings(rankings),
        skill_ids: faction_skills(skills), unknown: unknown, flags: flags}
  end

  defp format_value("BOOK", name, value) when name in ["NAME", "MODL", "FNAM", "ITEX", "SCRI", "ENAM"], do: strip_null(value)
  defp format_value("BOOK", "BKDT", <<weight::little-float-size(32),
    value::little-integer-size(32), scroll::little-integer-size(32),
    skill_id::signed-little-integer-size(32), enchantment::little-integer-size(32)>>) do
      skill_id = if skill_id > 0, do: skill_id, else: nil
      %{weight: weight, value: value, scroll: scroll == 1, skill_id: skill_id, enchantment: enchantment}
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

  defp format_value("SKIL", "INDX", <<size::little-integer-size(32)>>), do: size
  defp format_value("SKIL", "SKDT", <<attribute_id::little-integer-size(32),
    specialization_id::little-integer-size(32), uses::binary>>) do
      %{attribute_id: attribute_id, specialization_id: specialization_id, uses: uses}
  end

  defp format_value(_type, _name, value), do: value

  defp strip_null(value)
  defp strip_null(name), do: String.split(name, <<0>>, parts: 2) |> List.first

  defp record_pair_key(list, key, value) do
    Map.update(list, key, [{value, nil}], &([{value, nil} | &1]))
  end

  defp record_pair_value(list, key, value) do
    Map.update!(list, key, fn([{key, nil} | rest]) -> [{key, value} | rest] end)
  end

  defp record_list(list, key, value) do
    Map.update(list, key, [value], &(&1 ++ [value]))
  end

  defp faction_skills(skills), do: faction_skills(skills, [])
  defp faction_skills("", list), do: Enum.reverse(list)
  defp faction_skills(<<-1::signed-little-integer-size(32), _rest::binary>>, list), do: list
  defp faction_skills(<<skill::signed-little-integer-size(32), rest::binary>>, list) do
    faction_skills(rest, [skill | list])
  end

  defp faction_rankings(rankings), do: faction_rankings(rankings, [])
  defp faction_rankings("", list), do: Enum.reverse(list)
  defp faction_rankings(<<attribute_1::little-integer-size(32), attribute_2::little-integer-size(32),
    skill_1::little-integer-size(32), skill_2::little-integer-size(32), faction::little-integer-size(32),
    rest::binary>>, list) do
      faction_rankings(rest, [%{attribute_1: attribute_1, attribute_2: attribute_2, skill_1: skill_1,
        skill_2: skill_2, faction: faction} | list])
  end
end
