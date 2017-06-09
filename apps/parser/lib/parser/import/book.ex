defmodule Parser.Import.Book do
  @moduledoc """
  Functions to assist in importing books into the database. These are used by
  Mix.Tasks.Parser.Import during the import process.
  """

  @behaviour Parser.Import.RecordType

  alias Parser.Filter
  alias Codex.Book

  def filter_records(stream), do: Filter.by_type(stream, :book)
  def build_changeset(record), do: Book.changeset(record)
end
