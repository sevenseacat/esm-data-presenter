defmodule Mix.Tasks.Parser.Import do
  @moduledoc """
  Import different categories of data into the database.

  ## Examples

      $ mix parser.import skill
  """

  use Mix.Task
  import Mix.Ecto
  alias Codex.Repo
  alias Parser.{EsmFile, Filter}
  alias Ecto.Multi

  @supported_types ["skill", "book", "faction"]

  @spec run(type :: [String.t()]) :: any()
  def run([type]) when type in @supported_types do
    ensure_started Repo, []
    class = :"Elixir.Codex.#{String.capitalize(type)}"

    Mix.shell.info("Deleting old #{type} records...")
    Repo.delete_all(class)

    Mix.shell.info("Importing new #{type} records...")

    EsmFile.stream
    |> Filter.by_type(String.to_atom(type))
    |> Stream.map(&(apply(class, :changeset, [&1])))
    |> Enum.reduce(Multi.new, fn changeset, transaction ->
      Multi.insert(transaction, changeset.changes.id, changeset)
    end)
    |> Repo.transaction
  end

  def run(_args) do
    Enum.map(@supported_types, fn type -> run([type]) end)
  end
end
