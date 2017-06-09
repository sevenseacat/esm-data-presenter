defmodule Parser.Import.Enchantment do
  @moduledoc """
  Functions to assist in importing enchantments into the database. These are used by
  Mix.Tasks.Parser.Import during the import process.
  """

  @behaviour Parser.Import.RecordType

  alias Parser.Filter
  alias Codex.Enchantment

  def filter_records(stream), do: Filter.by_type(stream, :enchantment)
  def build_changeset(record), do: Enchantment.changeset(record)
end
