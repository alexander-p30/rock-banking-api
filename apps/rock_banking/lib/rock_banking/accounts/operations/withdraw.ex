defmodule RockBanking.Accounts.Operations.Withdraw do
  @moduledoc """
  Withdraw operation for an account.
  """

  alias RockBanking.Accounts.Schemas.Account
  alias RockBanking.Accounts.Operations.Notification
  alias RockBanking.ErrorSanitize
  alias RockBanking.Repo

  @spec withdraw(any, any) ::
          {:ok, %RockBanking.Accounts.Schemas.Account{}}
          | {:error,
             %{
               optional(:account) => String.t() | [binary | map],
               optional(:value) => String.t() | [binary | map],
               optional(atom) => [binary | map]
             }, %{account: any}}
  def withdraw(account = %Account{}, value) when is_integer(value) and value >= 0 do
    case do_withdraw(account, value) do
      {:ok, account = %Account{}} ->
        {:ok, Notification.send_email(account, :withdraw)}

      {:error, invalid_changeset = %Ecto.Changeset{}} ->
        {:error, ErrorSanitize.to_message_map(invalid_changeset), %{account: account}}
    end
  end

  def withdraw(account = %Account{}, _value),
    do: {:error, %{value: "must be an integer greater than or equal to 0"}, %{account: account}}

  def withdraw(account, _value),
    do: {:error, %{account: "must be of type %Account{}"}, %{account: account}}

  defp do_withdraw(account, value) do
    account
    |> Account.changeset(%{balance: account.balance - value})
    |> Repo.update()
  end
end
