defmodule Tes.EsmFile do
  @doc """
  Example:

  iex> Tes.EsmFile.stream("data/Morrowind.esm") |> Stream.run
  [%Tes.Book{...}, %Tes.Weapon{...}, ...]
  """
  def stream(filename) do
    Stream.resource(
      fn -> File.open!(filename, [:binary]) end,
      fn(file) -> next_record(file) end,
      fn(file) -> File.close(file) end
    )
  end

  @doc """
  The ESM/ESP/ESS files are composed entirely of records with the following format:

  Record
	4 bytes: char Name[4]
		4-byte record name string (not null-terminated)
	4 bytes: long Size
		Size of the record not including the 16 bytes of header data.
	4 bytes: long Header1
		Unknown value, usually 0 (deleted/ignored flag?).
	4 bytes: long Flags
		Record flags.
			 0x00002000 = Blocked
			 0x00000400 = Persistant
	? bytes: SubRecords[]
		All records are composed of a variable number of sub-records. There
		is no sub-record count, just use the record Size value to determine
		when to stop reading a record.

  File format taken from http://www.uesp.net/morrow/tech/mw_esm.txt
  """
  defp next_record(file) do
    case IO.binread(file, 16) do
      :eof -> {:halt, file}
      <<type::binary-size(4), size::little-integer-size(32), _header1::bytes-size(4), _flags::bytes-size(4)>> ->
        subrecords = IO.binread(file, size) |> parse_sub_records(type, %{})
        {[build_record(type, subrecords)], file}
    end
  end

  defp build_record("SKIL", subrecords), do: Tes.EsmFormatter.skill(subrecords)
  defp build_record("BOOK", subrecords), do: Tes.EsmFormatter.book(subrecords)
  defp build_record(type, subrecords), do: %{type: type, subrecords: subrecords}

  @doc """
  All records, as shown above, are again composed entirely of a variable number of
  sub-records with a similar format, as given below:

  Sub-Record
	4 bytes: char Name[4]
		4-byte sub-record name string (not null-terminated)
	4 bytes: long Size
		Size of the sub-record not including the 8 bytes of header data.
	? bytes: Sub-Record data.
		Format depends on the sub-record type (see below).

  File format taken from http://www.uesp.net/morrow/tech/mw_esm.txt
  """
  defp parse_sub_records("", _type, list), do: list
  defp parse_sub_records(<<name::binary-size(4), size::little-integer-size(32), rest::binary>>, type, list) do
    # Split the "rest" out into the content for this sub-record, and the rest
    value = binary_part(rest, 0, size)
    rest = binary_part(rest, size, (byte_size(rest)-size))

    new_list = record_value(list, name, format_value(type, name, value))
    parse_sub_records(rest, type, new_list)
  end

  @doc """
  Later down the track a function head can be added for lists of properties, eg. NPC-held items or dialogue conditions
  """
  def record_value(list, name, value), do: Map.put_new(list, name, value)

  @doc """
  For type-specific formatting.
  eg. some fields are null-terminated strings, some are bitmasks, some are little-endian integers
  """
  defp format_value("BOOK", name, value) when name in ["NAME", "MODL", "FNAM", "ITEX", "SCRI", "ENAM"], do: strip_null(value)
  defp format_value("BOOK", "BKDT", <<weight::little-float-size(32),
    value::little-integer-size(32), scroll::little-integer-size(32), skill_id::signed-little-integer-size(32),
    enchantment::little-integer-size(32)>>) do
      skill_id = if skill_id > 0, do: skill_id, else: nil
      %{weight: weight, value: value, scroll: scroll == 1, skill_id: skill_id, enchantment: enchantment}
  end
  defp format_value("BOOK", "TEXT", value) do
    # 147 and 148 are Windows-specific smart quotes - replace with Unicode quotes
    value |> String.replace(<<147>>, "“") |> String.replace(<<148>>, "”")
  end

  defp format_value("SKIL", "INDX", <<size::little-integer-size(32)>>), do: size
  defp format_value("SKIL", "SKDT", <<attribute_id::little-integer-size(32),
    specialization_id::little-integer-size(32), uses::binary>>) do
      %{attribute_id: attribute_id, specialization_id: specialization_id, uses: uses}
  end

  defp format_value(_type, _name, value), do: value

  defp strip_null(name), do: String.trim_trailing name, <<0>>
end