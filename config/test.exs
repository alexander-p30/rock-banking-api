use Mix.Config

config :rock_banking, RockBanking.Repo,
  username: "postgres",
  password: "postgres",
  database: "rock_banking_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :rock_banking_web, RockBankingWeb.Endpoint,
  http: [port: 4002],
  server: false

config :logger, level: :warn
