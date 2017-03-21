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

  @supported_types ["skill", "faction", "magic_effect"]

  @spec run(type :: [String.t()]) :: any()
  def run([type]) when type in @supported_types do
    ensure_started Repo, []
    class = :"Elixir.Codex.#{to_module_name(type)}"

    shiny_output(type, class, fn ->
      EsmFile.stream
      |> Filter.by_type(String.to_atom(type))
      |> Stream.map(&(apply(class, :changeset, [&1])))
      |> Enum.reduce(Multi.new, fn changeset, transaction ->
        Multi.insert(transaction, changeset.changes.name, changeset)
      end)
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
  defp shiny_output(type, class, func) do
    Logger.configure(level: :info)
    spinner_format = [frames: :braille, spinner_color: IO.ANSI.blue, done: :remove]

    Mix.shell.info("==> #{type}")
    spinner_format
    |> Keyword.merge([
        text: "Deleting old records...",
        done: [IO.ANSI.green, "✓ ", IO.ANSI.reset, "Deleted old records."]
      ])
    |> ProgressBar.render_spinner(fn -> Repo.delete_all(class) end)

    spinner_format
    |> Keyword.merge([text: "Importing new records..."])
    |> ProgressBar.render_spinner(fn -> func.() end)
    |> display_result
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

  # Converts underscore-form names such as "magic_effect" to module names like "MagicEffect".
  defp to_module_name(value) do
    value |> String.split("_") |> Enum.map(&(String.capitalize(&1))) |> Enum.join
  end
end
