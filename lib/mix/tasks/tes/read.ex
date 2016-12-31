defmodule Mix.Tasks.Tes.Read do
  use Mix.Task

  @filename "./data/Morrowind.esm"

  def run(_args) do
    Tes.EsmFile.stream(@filename)
    |> Stream.run
  end
end
