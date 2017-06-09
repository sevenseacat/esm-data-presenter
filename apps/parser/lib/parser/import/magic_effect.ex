defmodule Parser.Import.MagicEffect do
  @moduledoc """
  Functions to assist in importing magic effects into the database. These are used by
  Mix.Tasks.Parser.Import during the import process.
  """

  @behaviour Parser.Import.RecordType

  alias Parser.Filter
  alias Codex.MagicEffect

  def filter_records(stream), do: Filter.by_type(stream, :magic_effect)
  def build_changeset(record), do: MagicEffect.changeset(record)
end
