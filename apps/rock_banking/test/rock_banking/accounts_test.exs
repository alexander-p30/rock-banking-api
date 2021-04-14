defmodule RockBanking.AccountsTest do
  use RockBanking.DataCase

  alias RockBanking.Accounts
  alias RockBanking.Accounts.Schemas.Account
  alias RockBanking.Repo

  @valid_attrs %{name: "At Least Three", email: "valid@email.com"}
  @default_bonus_balance 1000_00

  describe "create" do
    test "successfully create user when all attributes are valid" do
      attrs = @valid_attrs

      assert {:ok, %Account{} = account} = Accounts.create(attrs)
      assert account.name == attrs.name
      assert account.email == attrs.email
      assert [account] == Repo.all(Account)
    end

    test "add default bonus balance on account creation" do
      attrs = @valid_attrs

      assert {:ok, %Account{} = account} = Accounts.create(attrs)
      assert account.name == attrs.name
      assert account.email == attrs.email
      assert [account] == Repo.all(Account)
      assert account.balance == @default_bonus_balance
    end

    test "fail when name lenght is lower than 3" do
      attrs = %{@valid_attrs | name: "Ab"}

      assert {:error, changeset = %Ecto.Changeset{}} = Accounts.create(attrs)
      assert %{name: ["should be at least 3 character(s)"]} == errors_on(changeset)
    end

    test "fail when email does not match email regex" do
      attrs = %{@valid_attrs | email: "not_validmail.com"}

      assert {:error, changeset = %Ecto.Changeset{}} = Accounts.create(attrs)
      assert %{email: ["has invalid format"]} == errors_on(changeset)
    end

    test "fail when email has already been taken" do
      attrs = @valid_attrs

      assert {:ok, %Account{} = account} = Accounts.create(attrs)
      assert account.name == attrs.name
      assert account.email == attrs.email
      assert account.balance == @default_bonus_balance
      assert [account] == Repo.all(Account)

      assert {:error, changeset = %Ecto.Changeset{}} = Accounts.create(attrs)
      assert %{email: ["has already been taken"]} == errors_on(changeset)
    end
  end
end
