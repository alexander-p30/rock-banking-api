defmodule RockBanking.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      RockBanking.Repo,
      {Phoenix.PubSub, name: RockBanking.PubSub}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: RockBanking.Supervisor)
  end
end
