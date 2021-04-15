defmodule RockBankingWeb.Api.V1.AccountController do
  @moduledoc """
  Controller for dealing with account-related requests.
  """
  use RockBankingWeb, :controller

  alias RockBanking.Accounts
  alias RockBanking.Accounts.Inputs
  alias RockBankingWeb.InputValidate
  alias RockBanking.ErrorSanitize

  def create(conn, params) do
    with {:ok, input} <- validate_input(params),
         {:ok, account} <- Accounts.create(input) do
      send_json(conn, 200, account)
    else
      {:error, changeset = %Ecto.Changeset{valid?: false}} ->
        error_message = %{reason: "bad input", details: ErrorSanitize.to_message_map(changeset)}
        send_json(conn, 412, error_message)

      {:error, error_details} ->
        error_message = %{reason: "bad input", details: error_details}
        send_json(conn, 400, error_message)
    end
  end

  defp validate_input(params) do
    params
    |> Inputs.Create.changeset()
    |> InputValidate.validate()
  end

  defp send_json(conn, status, body) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(status, Jason.encode!(body))
  end
end
