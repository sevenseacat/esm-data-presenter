use Mix.Config

config :parser, Tes.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "tes_dev",
  hostname: "localhost",
  pool_size: 10
