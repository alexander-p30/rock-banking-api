defmodule RockBankingWeb.Router do
  use RockBankingWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/v1", RockBankingWeb.Api.V1 do
    pipe_through :api

    post "/accounts", AccountController, :create
    post "/accounts/transfer", AccountController, :transfer
  end
end
