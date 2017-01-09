defmodule Mix.Tasks.Tes.Import do
  use Mix.Task
  import Mix.Ecto
  alias Tes.{Repo, EsmFile, Filter}

  @supported_types ["skill", "book", "faction"]

  def run([type]) when type in @supported_types do
    ensure_started Repo, []
    class = :"Elixir.Tes.#{String.capitalize(type)}"

    Mix.shell.info("Deleting old #{type} records...")
    Repo.delete_all(class)

    Mix.shell.info("Importing new #{type} records...")
    EsmFile.stream
    |> Filter.by_type(String.to_atom(type))
    |> Stream.map(&(apply(class, :changeset, [&1])))
    |> Enum.map(&Repo.insert!/1)
  end

  def run(_args) do
    Mix.shell.error("Please specify a type of object to import, eg. `mix tes.import skill`")
  end
end
