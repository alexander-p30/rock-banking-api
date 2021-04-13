# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

# Configure Mix tasks and generators
config :rock_banking,
  ecto_repos: [RockBanking.Repo]

config :rock_banking_web,
  ecto_repos: [RockBanking.Repo],
  generators: [context_app: :rock_banking, binary_id: true]

# Configures the endpoint
config :rock_banking_web, RockBankingWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "7BHjcAcI5kNLOdHvrghvmv2eGL5N8GxasHQ88Sv9UY7DFWsc3vJg8DmTbL7/Y1ui",
  render_errors: [view: RockBankingWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: RockBanking.PubSub,
  live_view: [signing_salt: "JNihsrLz"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
