defmodule RockBanking.Accounts.Operations.Withdraw do
  @moduledoc """
  Withdraw operation for an account.
  """

  alias RockBanking.Accounts.Schemas.Account
  alias RockBanking.Repo

  def withdraw(account = %Account{}, value) when is_integer(value) and value >= 0 do
    case do_withdraw(account, value) do
      {:ok, account = %Account{}} ->
        {:ok, account}

      {:error, invalid_changeset = %Ecto.Changeset{}} ->
        {:error, %{reason: invalid_changeset.errors, account: account}}
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
