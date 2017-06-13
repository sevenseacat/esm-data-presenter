defmodule Parser.Import.Apparatus do
  @moduledoc """
  Functions to assist in importing apparatus into the database. These are used by
  Mix.Tasks.Parser.Import during the import process.
  """

  @behaviour Parser.Import.RecordType

  alias Parser.Filter
  alias Codex.Apparatus

  def filter_records(stream), do: Filter.by_type(stream, :apparatus)
  def build_changeset(record), do: Apparatus.changeset(record)
end
