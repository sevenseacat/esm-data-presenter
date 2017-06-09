defmodule Parser.Import.Script do
  @moduledoc """
  Functions to assist in importing scripts into the database. These are used by
  Mix.Tasks.Parser.Import during the import process.
  """

  @behaviour Parser.Import.RecordType

  alias Parser.Filter
  alias Codex.Script

  def filter_records(stream), do: Filter.by_type(stream, :script)
  def build_changeset(record), do: Script.changeset(record)
end
