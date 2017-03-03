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
    |> Enum.map(&Repo.insert!/1)
  end

  def run(_args) do
    Mix.shell.error("Please specify a type of object to import, eg. `mix parser.import skill`")
  end
end
