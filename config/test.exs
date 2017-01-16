use Mix.Config

# Configure your database
config :tes, Tes.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "tes_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
