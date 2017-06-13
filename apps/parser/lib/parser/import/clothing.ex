defmodule Parser.Import.Clothing do
  @moduledoc """
  Functions to assist in importing clothing into the database. These are used by
  Mix.Tasks.Parser.Import during the import process.
  """

  @behaviour Parser.Import.RecordType

  alias Parser.Filter
  alias Codex.Clothing

  def filter_records(stream), do: Filter.by_type(stream, :clothing)
  def build_changeset(record), do: Clothing.changeset(record)
end
