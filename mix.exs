defmodule Tes.Mixfile do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixir: "~> 1.7",
      preferred_cli_env: [inch: :docs],
      aliases: aliases()
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options.
  #
  # Dependencies listed here are available only for this project
  # and cannot be accessed from applications inside the apps folder
  defp deps do
    [
      {:credo, "~> 0.7", only: [:dev, :test]},
      {:ex_doc, "~> 0.14", only: [:dev]},
      {:inch_ex, ">= 0.0.0", only: [:docs]}
    ]
  end

  defp aliases do
    [
      "parser.import": ["compile", "parser.import"]
    ]
  end
end
