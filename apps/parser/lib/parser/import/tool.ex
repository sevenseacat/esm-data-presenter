defmodule Parser.Import.Tool do
  @moduledoc """
  Functions to assist in importing tools into the database. These are used by
  Mix.Tasks.Parser.Import during the import process.
  """

  @behaviour Parser.Import.RecordType

  alias Parser.Filter
  alias Codex.Tool

  def filter_records(stream), do: Filter.by_types(stream, [:probe, :lockpick, :repair])
  def build_changeset({type, record}) do
    record
    |> Map.put(:type, Atom.to_string(type))
    |> Tool.changeset
  end
end
