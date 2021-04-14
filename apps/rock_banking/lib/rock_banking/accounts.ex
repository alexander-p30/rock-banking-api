defmodule RockBanking.Accounts do
  @moduledoc """
  Domain logic for accounts.
  """

  alias RockBanking.Accounts.Schemas.Account
  alias RockBanking.Repo

  import Ecto.Changeset

  @default_bonus_balance 1000_00

  def create(attrs) do
    %Account{}
    |> Account.changeset(attrs)
    |> apply_creation_bonus()
    |> Repo.insert()
  end

  defp apply_creation_bonus(account = %Ecto.Changeset{}) do
    cast(account, %{balance: @default_bonus_balance}, [:balance])
  end
end
