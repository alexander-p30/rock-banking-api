use Mix.Config

config :rock_banking,
  ecto_repos: [RockBanking.Repo]

config :rock_banking_web,
  ecto_repos: [RockBanking.Repo],
  generators: [context_app: :rock_banking, binary_id: true]

config :rock_banking_web, RockBankingWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "7BHjcAcI5kNLOdHvrghvmv2eGL5N8GxasHQ88Sv9UY7DFWsc3vJg8DmTbL7/Y1ui",
  render_errors: [view: RockBankingWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: RockBanking.PubSub,
  live_view: [signing_salt: "JNihsrLz"]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{Mix.env()}.exs"
