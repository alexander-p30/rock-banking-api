defmodule RockBanking.Accounts.Operations.Withdraw do
  @moduledoc """
  Withdraw operation for an account.
  """

  alias RockBanking.Accounts.Schemas.Account
  alias RockBanking.ErrorSanitize
  alias RockBanking.Repo

  @error_messages %{balance: [greater_than_or_equal_to: :insufficient_balance]}

  def withdraw(account = %Account{}, value) when is_integer(value) and value >= 0 do
    case do_withdraw(account, value) do
      {:ok, account = %Account{}} ->
        {:ok, account}

      {:error, invalid_changeset = %Ecto.Changeset{}} ->
        {:error, ErrorSanitize.to_status_list(invalid_changeset.errors, @error_messages),
         %{account: account}}
    end
  end

  def withdraw(account, _value),
    do: {:error, %{reason: "Invalid account or value", account: account}}

  defp do_withdraw(account, value) do
    account
    |> Account.changeset(%{balance: account.balance - value})
    |> Repo.update()
  end
end
