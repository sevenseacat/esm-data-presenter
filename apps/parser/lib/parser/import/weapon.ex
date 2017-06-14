defmodule Parser.Import.Weapon do
  @moduledoc """
  Functions to assist in importing weapons into the database. These are used by
  Mix.Tasks.Parser.Import during the import process.
  """

  @behaviour Parser.Import.RecordType

  alias Parser.Filter
  alias Codex.Weapon

  def filter_records(stream), do: Filter.by_type(stream, :weapon)
  def build_changeset(record), do: Weapon.changeset(record)
end
