defmodule Mix.Tasks.Tes.Read do
  use Mix.Task

  @filename "./data/Morrowind.esm"

  def run(_args) do
    Tes.Parser.new(@filename)
    |> Stream.run
  end
end
