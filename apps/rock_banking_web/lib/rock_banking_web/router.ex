defmodule RockBankingWeb.Router do
  use RockBankingWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", RockBankingWeb do
    pipe_through :api
  end
end
