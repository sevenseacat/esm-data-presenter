defmodule Mix.Tasks.Parser.Import do
  @moduledoc """
  Import different categories of data into the database.

  ## Examples

      $ mix parser.import Skill
  """

  use Mix.Task
  import Mix.Ecto
  alias Codex.{Repo, Object}
  alias Parser.EsmFile
  alias Ecto.Multi

  @supported_types ~w(Skill Faction MagicEffect Enchantment Script Book Class Armor Ingredient Tool
    Apparatus Clothing)

  @spec run(type :: [String.t()]) :: any()
  def run([type]) when type in @supported_types do
    ensure_started Repo, []
    module = import_module(type)

    shiny_output(type, fn ->
      module
      |> apply(:filter_records, [EsmFile.stream])
      |> Stream.map(&(apply(module, :build_changeset, [&1])))
      |> Enum.reduce({0, Multi.new}, fn changeset, {index, transaction} ->
        {index + 1, Multi.insert(transaction, index, changeset)}
      end)
      |> elem(1)
      |> Repo.transaction
    end)
  end

  def run([]) do
    Enum.each(@supported_types, fn type -> run([type]) end)
  end

  def run([arg]) do
    Mix.shell.error("Unknown data type: #{arg}")
  end

  # Adds a lot of nice formatting things like silent SQL logs, spinners, and other shiny.
  defp shiny_output(type, func) do
    Logger.configure(level: :info)
    spinner_format = [frames: :braille, spinner_color: IO.ANSI.blue, done: :remove]

    Mix.shell.info("==> #{type}")
    spinner_format
    |> Keyword.merge([
        text: "Deleting old records...",
        done: [IO.ANSI.green, "✓ ", IO.ANSI.reset, "Deleted old records."]
      ])
    |> ProgressBar.render_spinner(fn -> delete_all_the_things(type) end)

    spinner_format
    |> Keyword.merge([text: "Importing new records..."])
    |> ProgressBar.render_spinner(fn -> func.() end)
    |> display_result
  end

  defp delete_all_the_things(type) do
    type
    |> Object.schema_module
    |> apply(:all, [])
    |> Repo.delete_all
  end

  defp display_result({:ok, records}) do
    Mix.shell.info([
      IO.ANSI.green, "✓ ", IO.ANSI.reset,
      "#{map_size(records)} records imported successfully.\n"
    ])
  end

  defp display_result({:error, _failed_operation, failed_value, _changes_so_far}) do
    Mix.shell.error("Error when processing #{inspect(failed_value)}")
    exit(:error)
  end

  defp import_module(type) do
    :"Elixir.Parser.Import.#{type}"
  end
end
