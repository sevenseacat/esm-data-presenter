defmodule Codex.ConnCase do
  @moduledoc """
  A common ExUnit module for setting up tests.

  Sets up Ecto sandboxes, ExMachina factories, and defines some common helper methods.
  """

  alias Codex.{Factory, Repo}
  alias Ecto.Adapters.SQL.Sandbox
  use ExUnit.CaseTemplate

  using do
    quote do
      import Codex.{ConnCase, Factory}
    end
  end

  setup tags do
    :ok = Sandbox.checkout(Repo)

    unless tags[:async] do
      Sandbox.mode(Repo, {:shared, self()})
    end

    {:ok, []}
  end

  @spec errors(Ecto.Changeset.t) :: [{atom, string}]
  def errors(changeset) do
    changeset.errors
    |> Enum.map(fn {field, {message, _rule}} -> {field, message} end)
  end
end
