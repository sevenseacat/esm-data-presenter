defmodule Parser.Import.MiscItem do
  @moduledoc """
  Functions to assist in importing miscellaneous items into the database. These are used by
  Mix.Tasks.Parser.Import during the import process.
  """

  @behaviour Parser.Import.RecordType

  alias Parser.Filter
  alias Codex.MiscItem

  def filter_records(stream), do: Filter.by_type(stream, :misc_item)
  def build_changeset(record), do: MiscItem.changeset(record)
end
