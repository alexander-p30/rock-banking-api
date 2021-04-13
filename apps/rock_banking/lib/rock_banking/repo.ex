defmodule RockBanking.Repo do
  use Ecto.Repo,
    otp_app: :rock_banking,
    adapter: Ecto.Adapters.Postgres
end
