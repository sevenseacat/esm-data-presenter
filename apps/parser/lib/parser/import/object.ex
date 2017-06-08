defmodule Parser.Import.Object do
  @moduledoc """
  Lists functions that must be defined by any record type that wants to be imported into the
  database. For the most part they will be very simple - using Parser.Filter and basic schema
  modules - but this does allow for customization for more complicated scenarios.
  """

  @callback filter_records(Stream.t) :: Stream.t
  @callback build_changeset(Struct.t) :: Ecto.Changeset.t
end
