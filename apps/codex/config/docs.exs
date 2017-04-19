use Mix.Config

config :codex, Codex.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "tes_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
