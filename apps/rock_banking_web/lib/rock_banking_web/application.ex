defmodule RockBankingWeb.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      RockBankingWeb.Telemetry,
      RockBankingWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: RockBankingWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    RockBankingWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
