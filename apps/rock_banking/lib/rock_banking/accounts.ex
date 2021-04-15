defmodule RockBanking.Accounts do
  @moduledoc """
  Domain logic for accounts.
  """

  alias RockBanking.Accounts.Operations.{Transfer, Withdraw}
  alias RockBanking.Accounts.Schemas.Account
  alias RockBanking.Repo

  import Ecto.Changeset

  @default_bonus_balance 1000_00
  @schema_attrs [:name, :email, :balance]

  @doc """
  Create record on accounts table and sets initial balance to given balance +
  #{@default_bonus_balance}.

  Returns either {:ok, account} or {:error, changeset}.
  """
  @spec create(%{}) :: {:ok, %Account{}} | {:error, %Ecto.Changeset{}}
  def create(attrs = %{}) do
    attrs = struct_to_map(@schema_attrs, attrs)

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
  @spec transfer(any, any, any) ::
          {:ok, %{origin_account: %Account{}, destination_account: %Account{}}}
  def transfer(origin, destination, value), do: Transfer.transfer(origin, destination, value)

  @doc """
  Withdraw money from account given that the supplied value is valid and account has
  sufficient balance.

  Returns either {:ok, account_map} or {:error, error_status_list, account_map}.
  """
  @spec withdraw(any, any) ::
          {:ok, %Account{}} | {:error, %{atom() => String.t()}, %{account: %Account{}}}
  def withdraw(account, value), do: Withdraw.withdraw(account, value)

  @doc """
  Fetch a specific record from database given a valid id.

  Returns {:ok, record}, {:error, :not_found} or {:error, :invalid_id}.
  """
  @spec fetch(any) :: {:ok, %Account{}} | {:error, :not_found | :invalid_id}
  def fetch(account_id) when is_binary(account_id) do
    case Repo.get(Account, account_id) do
      nil -> {:error, :not_found}
      account = %Account{} -> {:ok, account}
    end
  end

  def fetch(_account_id), do: {:error, :invalid_id}

  defp struct_to_map(attribute_list, struct) do
    attribute_list
    |> Enum.map(fn attribute ->
      attribute_value =
        case Map.fetch(struct, attribute) do
          {:ok, value} -> value
          :error -> nil
        end

      {attribute, attribute_value}
    end)
    |> Map.new()
  end

  defp apply_creation_bonus(account = %Ecto.Changeset{}) do
    previous_balance = account.changes[:balance] || 0
    cast(account, %{balance: previous_balance + @default_bonus_balance}, [:balance])
  end
end
