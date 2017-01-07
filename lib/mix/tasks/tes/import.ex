defmodule Mix.Tasks.Tes.Import do
  use Mix.Task
  import Mix.Ecto

  def run(["skill"]) do
    ensure_started Tes.Repo, []

    Mix.shell.info("Deleting old skills...")
    Tes.Repo.delete_all(Tes.Skill)

    Tes.EsmFile.stream
    |> Tes.Filter.by_type(:skill)
    |> Stream.map(&Tes.Skill.changeset/1)
    |> Enum.map(&Tes.Repo.insert!/1)
  end

  def run(_args) do
    Mix.shell.error("Please specify a type of object to import, eg. `mix tes.import skill`")
  end
end
