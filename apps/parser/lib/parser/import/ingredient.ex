defmodule Parser.Import.Ingredient do
  @moduledoc """
  Functions to assist in importing ingredients into the database. These are used by
  Mix.Tasks.Parser.Import during the import process.
  """

  @behaviour Parser.Import.RecordType

  alias Parser.Filter
  alias Codex.Ingredient

  def filter_records(stream), do: Filter.by_type(stream, :ingredient)
  def build_changeset(record), do: Ingredient.changeset(record)
end
