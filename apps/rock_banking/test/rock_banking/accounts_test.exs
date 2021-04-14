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

    test "add default bonus balance on account creation with a given balance" do
      preset_balance = 500_00
      attrs = Map.put(@valid_attrs, :balance, preset_balance)

      assert {:ok, %Account{} = account} = Accounts.create(attrs)
      assert account.name == attrs.name
      assert account.email == attrs.email
      assert [account] == Repo.all(Account)
      assert account.balance == @default_bonus_balance + preset_balance
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

  describe "transfer" do
    setup do
      origin_attrs = %{name: "First Account Name", email: "facc@email.com"}
      destination_attrs = %{name: "Second Account Name", email: "sacc@email.com"}

      {:ok, origin_account = %Account{}} = Accounts.create(origin_attrs)
      {:ok, destination_account = %Account{}} = Accounts.create(destination_attrs)

      %{origin_account: origin_account, destination_account: destination_account}
    end

    test "transfers value from two accounts when parameters are valid", %{
      origin_account: origin_account,
      destination_account: destination_account
    } do
      original_balance = @default_bonus_balance
      transfer_value = 300_00

      assert {:ok, %{origin: origin_account, destination: destination_account}} =
               Accounts.transfer(origin_account, destination_account, transfer_value)

      assert origin_account.balance == original_balance - transfer_value
      assert destination_account.balance == original_balance + transfer_value
    end

    test "fail when value is not positive or 0", %{
      origin_account: origin_account,
      destination_account: destination_account
    } do
      original_balance = @default_bonus_balance
      transfer_value = -500_00

      assert {:error,
              %{
                reason: "invalid accounts or value",
                origin_account: origin_account,
                destination_account: destination_account
              }} = Accounts.transfer(origin_account, destination_account, transfer_value)

      assert origin_account.balance == original_balance
      assert destination_account.balance == original_balance
    end

    test "fail when origin balance is not sufficient", %{
      origin_account: origin_account,
      destination_account: destination_account
    } do
      original_balance = @default_bonus_balance
      transfer_value = 5000_00

      insufficient_balance_error = [
        balance:
          {"must be greater than or equal to %{number}",
           [validation: :number, kind: :greater_than_or_equal_to, number: 0]}
      ]

      assert {:error,
              %{
                reason: ^insufficient_balance_error,
                origin_account: origin_account,
                destination_account: destination_account
              }} = Accounts.transfer(origin_account, destination_account, transfer_value)

      assert origin_account.balance == original_balance
      assert destination_account.balance == original_balance
    end
  end
end
