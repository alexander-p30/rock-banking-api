defmodule RockBanking.Accounts do
  @moduledoc """
  Domain logic for accounts.
  """

  alias RockBanking.Accounts.Operations.{Transfer, Withdraw}
  alias RockBanking.Accounts.Schemas.Account
  alias RockBanking.Repo

  import Ecto.Changeset

  @default_bonus_balance 1000_00

  def create(attrs = %{}) do
    %Account{}
    |> Account.changeset(attrs)
    |> apply_creation_bonus()
    |> Repo.insert()
  end

  @doc """
  Transfer money between origin and destination accounts given that supplied value is valid
  and origin account has sufficient balance.

  Returns either {:ok, accounts_map} or {:error, error_status_list, accounts_map}.
  """
  def transfer(origin, destination, value), do: Transfer.transfer(origin, destination, value)

  @doc """
  Withdraw money from account given that the supplied value is valid and account has
  sufficient balance.

  Returns either {:ok, account_map} or {:error, error_status_list, account_map}.
  """
  def withdraw(account, value), do: Withdraw.withdraw(account, value)

  @doc """
  Fetch a specific record from database given a valid id.

  Returns {:ok, record}, {:error, :not_found} or {:error, :invalid_id}.
  """
  def fetch(account_id) when is_binary(account_id) do
    case Repo.get(Account, account_id) do
      nil -> {:error, :not_found}
      account = %Account{} -> {:ok, account}
    end
  end

  def fetch(_account_id), do: {:error, :invalid_id}

  defp apply_creation_bonus(account = %Ecto.Changeset{}) do
    previous_balance = account.changes[:balance] || 0
    cast(account, %{balance: previous_balance + @default_bonus_balance}, [:balance])
  end
end
