defmodule Parser.Import.Armor do
  @moduledoc """
  Functions to assist in importing armor into the database. These are used by
  Mix.Tasks.Parser.Import during the import process.
  """

  @behaviour Parser.Import.RecordType

  alias Parser.Filter
  alias Codex.Armor

  def filter_records(stream), do: Filter.by_type(stream, :armor)
  def build_changeset(record), do: Armor.changeset(record)
end
