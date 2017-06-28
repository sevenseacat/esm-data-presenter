defmodule Parser.Import.Spell do
  @moduledoc """
  Functions to assist in importing spells into the database. These are used by
  Mix.Tasks.Parser.Import during the import process.
  """

  @behaviour Parser.Import.RecordType

  alias Parser.Filter
  alias Codex.Spell

  def filter_records(stream), do: Filter.by_type(stream, :spell)
  def build_changeset(record), do: Spell.changeset(record)
end
