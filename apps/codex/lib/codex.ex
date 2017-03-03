defmodule Codex do
  @moduledoc false

  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  # @spec taken from documentiation to make Credo happy :)
  @spec start(app :: term, type :: term) :: :ok | {:error, term}
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: Sample.Worker.start_link(arg1, arg2, arg3)
      # worker(Sample.Worker, [arg1, arg2, arg3]),
      supervisor(Codex.Repo, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Codex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
