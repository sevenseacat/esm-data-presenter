defmodule Parser.Import.Skill do
  @moduledoc """
  Functions to assist in importing skills into the database. These are used by
  Mix.Tasks.Parser.Import during the import process.
  """

  @behaviour Parser.Import.RecordType

  alias Parser.Filter
  alias Codex.Skill

  def filter_records(stream), do: Filter.by_type(stream, :skill)
  def build_changeset(record), do: Skill.changeset(record)
end
