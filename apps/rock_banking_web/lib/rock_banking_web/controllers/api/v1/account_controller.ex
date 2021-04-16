defmodule RockBankingWeb.Api.V1.AccountController do
  @moduledoc """
  Controller for dealing with account-related requests.
  """
  use RockBankingWeb, :controller

  alias RockBanking.Accounts
  alias RockBanking.Accounts.Inputs
  alias RockBankingWeb.InputValidate
  alias RockBanking.ErrorSanitize

  @doc """
  Create an account with the given params. May respond with 200, when successful, or 4xx when
  params are invalid.
  """
  def create(conn, params = %{"name" => _, "email" => _}) do
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

  def create(conn, params) do
    expected_params = ~w(name email)
    send_missing_params_response(conn, params, expected_params)
  end

  @doc """
  Attempts to transfer balance between accounts with given ids. May respond with 200, when
  successful, or 4xx when params are invalid.
  """
  def transfer(conn, %{
        "origin_account_id" => origin_account_id,
        "destination_account_id" => destination_account_id,
        "value" => value
      }) do
    with {:ok, origin_account} <- Accounts.fetch(origin_account_id),
         {:ok, destination_account} <- Accounts.fetch(destination_account_id),
         {:ok, _accounts = %{}} <- Accounts.transfer(origin_account, destination_account, value) do
      send_json(conn, 200, nil)
    else
      {:error, :not_found} ->
        send_json(conn, 404, %{reason: "account not found"})

      {:error, :invalid_id} ->
        error_message = %{reason: "invalid id", details: %{id: "provided id is not valid"}}
        send_json(conn, 400, error_message)

      {:error, error_details, _accounts} ->
        error_message = %{reason: "bad input", details: error_details}
        send_json(conn, 400, error_message)
    end
  end

  def transfer(conn, params) do
    expected_params = ~w(origin_account_id destination_account_id value)
    send_missing_params_response(conn, params, expected_params)
  end

  @doc """
  Attempts to withdraw balance form account with given id. May respond with 200, when successful
  or 4xx when params are invalid.
  """
  def withdraw(conn, %{"account_id" => account_id, "value" => value}) do
    with {:ok, account} <- Accounts.fetch(account_id),
         {:ok, _account = %{}} <- Accounts.withdraw(account, value) do
      send_json(conn, 200, nil)
    else
      {:error, :not_found} ->
        send_json(conn, 404, %{reason: "account not found"})

      {:error, :invalid_id} ->
        error_message = %{reason: "invalid id", details: %{id: "provided id is not valid"}}
        send_json(conn, 400, error_message)

      {:error, error_details, _accounts} ->
        error_message = %{reason: "bad input", details: error_details}
        send_json(conn, 400, error_message)
    end
  end

  def withdraw(conn, params) do
    expected_params = ~w(account_id value)
    send_missing_params_response(conn, params, expected_params)
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

  defp send_missing_params_response(conn, params, expected_params) do
    error_message = %{reason: "bad input", details: list_missing_params(params, expected_params)}
    send_json(conn, 400, error_message)
  end

  defp list_missing_params(params, expected_params) do
    expected_params
    |> Enum.reduce([], fn current_param, missing_params ->
      if params[current_param],
        do: missing_params,
        else: [{current_param, "required but missing"} | missing_params]
    end)
    |> Map.new()
  end
end
