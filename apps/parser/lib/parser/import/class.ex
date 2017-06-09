defmodule Parser.Import.Class do
  @moduledoc """
  Functions to assist in importing classes into the database. These are used by
  Mix.Tasks.Parser.Import during the import process.
  """

  @behaviour Parser.Import.RecordType

  alias Parser.Filter
  alias Codex.Class

  def filter_records(stream), do: Filter.by_type(stream, :class)
  def build_changeset(record), do: Class.changeset(record)
end
