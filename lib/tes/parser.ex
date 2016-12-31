defmodule Tes.Parser do
  @doc """
  Example:

  iex> Tes.Parser.new("data/Morrowind.esm") |> Stream.run
  """
  def new(filename) do
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
      header -> parse_record(header, file)
    end
  end

  defp parse_record(<<type::binary-size(4), size::little-integer-size(32), _header1::bytes-size(4), _flags::bytes-size(4)>>, file) do
    subrecords = IO.binread(file, size) |> parse_sub_records(type, [])
    {[[type, subrecords]], file}
  end

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
  defp parse_sub_records("", _type, list), do: Enum.reverse(list)
  defp parse_sub_records(<<name::binary-size(4), size::little-integer-size(32), rest::binary>>, type, list) do
    # Split the "rest" out into the content for this sub-record, and the rest
    value = binary_part(rest, 0, size)
    rest = binary_part(rest, size, (byte_size(rest)-size))

    parse_sub_records(rest, type, [{name, format_value(type, name, value)} | list])
  end

  @doc """
  For type-specific formatting.
  eg. some fields are null-terminated strings, some are bitmasks, some are little-endian integers
  """
  defp format_value("SKIL", "INDX", <<size::little-integer-size(32)>>), do: size
  defp format_value(_type, _name, value), do: value
end
