defmodule RockBanking.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      RockBanking.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: RockBanking.PubSub}
      # Start a worker by calling: RockBanking.Worker.start_link(arg)
      # {RockBanking.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: RockBanking.Supervisor)
  end
end
