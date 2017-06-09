defmodule Parser.Import.Faction do
  @moduledoc """
  Functions to assist in importing factions into the database. These are used by
  Mix.Tasks.Parser.Import during the import process.
  """

  @behaviour Parser.Import.RecordType

  alias Parser.Filter
  alias Codex.Faction

  def filter_records(stream), do: Filter.by_type(stream, :faction)
  def build_changeset(record), do: Faction.changeset(record)
end
