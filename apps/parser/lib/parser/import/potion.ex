defmodule Parser.Import.Potion do
  @moduledoc """
  Functions to assist in importing potions into the database. These are used by
  Mix.Tasks.Parser.Import during the import process.
  """

  @behaviour Parser.Import.RecordType

  alias Parser.Filter
  alias Codex.Potion

  def filter_records(stream), do: Filter.by_type(stream, :potion)
  def build_changeset(record), do: Potion.changeset(record)
end
