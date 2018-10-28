defmodule Codex.ConnCase do
  @moduledoc """
  A common ExUnit module for setting up tests.

  Sets up Ecto sandboxes, ExMachina factories, and defines some common helper methods.
  """

  alias Codex.{Factory, Repo}
  alias Ecto.{Adapters.SQL.Sandbox, Changeset}
  use ExUnit.CaseTemplate

  using do
    quote do
      import Codex.{ConnCase, Factory}
      alias Codex.Repo
    end
  end

  setup tags do
    :ok = Sandbox.checkout(Repo)

    unless tags[:async] do
      Sandbox.mode(Repo, {:shared, self()})
    end

    {:ok, []}
  end

  @spec errors(Ecto.Changeset.t()) :: [{atom, String.t()}]
  def errors(changeset) do
    changeset
    |> Changeset.traverse_errors(fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Map.to_list()
    |> Enum.map(fn {field, [message]} -> {field, message} end)
  end
end
