defmodule RockBanking.Accounts.Operations.Transfer do
  @moduledoc """
  Transfer operation between accounts.
  """

  alias RockBanking.Accounts.Schemas.Account
  alias RockBanking.Repo
  alias RockBanking.ErrorSanitize
  alias Ecto.Multi

  def transfer(origin, destination, value) do
    case safe_transfer(origin, destination, value) do
      {:ok, updated_accounts} ->
        {:ok, updated_accounts}

      {:error, reason, accounts = %{}} ->
        {:error, reason, accounts}

      {:error, _failed_operation, invalid_changeset, _changes} ->
        {:error, ErrorSanitize.to_message_map(invalid_changeset),
         %{
           origin_account: origin,
           destination_account: destination
         }}
    end
  end

  defp safe_transfer(origin = %Account{}, destination = %Account{}, value)
       when is_integer(value) and value > 0 do
    Multi.new()
    |> Multi.update(
      :origin,
      origin |> Account.changeset(%{balance: origin.balance - value})
    )
    |> Multi.update(
      :destination,
      destination |> Account.changeset(%{balance: origin.balance + value})
    )
    |> Repo.transaction()
  end

  defp safe_transfer(origin, destination, _value) do
    {:error, [:invalid_accounts_or_value],
     %{
       origin_account: origin,
       destination_account: destination
     }}
  end
end
