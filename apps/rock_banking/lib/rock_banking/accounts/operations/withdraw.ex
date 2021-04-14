defmodule RockBanking.Accounts.Operations.Withdraw do
  @moduledoc """
  Withdraw operation for an account.
  """

  alias RockBanking.Accounts.Schemas.Account
  alias RockBanking.Accounts.Operations.Notification
  alias RockBanking.ErrorSanitize
  alias RockBanking.Repo

  def withdraw(account = %Account{}, value) when is_integer(value) and value >= 0 do
    case do_withdraw(account, value) do
      {:ok, account = %Account{}} ->
        {:ok, account |> Notification.send_email(:withdraw)}

      {:error, invalid_changeset = %Ecto.Changeset{}} ->
        {:error, ErrorSanitize.to_message_map(invalid_changeset), %{account: account}}
    end
  end

  def withdraw(account, _value),
    do: {:error, :invalid_account_or_value, %{account: account}}

  defp do_withdraw(account, value) do
    account
    |> Account.changeset(%{balance: account.balance - value})
    |> Repo.update()
  end
end
