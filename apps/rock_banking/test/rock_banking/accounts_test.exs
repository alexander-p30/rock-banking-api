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

      assert {:error, changeset = %Ecto.Changeset{valid?: false}} = Accounts.create(attrs)
      assert %{name: ["should be at least 3 character(s)"]} == errors_on(changeset)
    end

    test "fail when email does not match email regex" do
      attrs = %{@valid_attrs | email: "a"}

      assert {:error, changeset = %Ecto.Changeset{valid?: false}} = Accounts.create(attrs)
      assert %{email: ["has invalid format"]} == errors_on(changeset)
    end

    test "fail when email has already been taken" do
      attrs = @valid_attrs

      assert {:ok, %Account{} = account} = Accounts.create(attrs)
      assert account.name == attrs.name
      assert account.email == attrs.email
      assert account.balance == @default_bonus_balance
      assert [account] == Repo.all(Account)

      assert {:error, changeset = %Ecto.Changeset{valid?: false}} = Accounts.create(attrs)
      assert %{email: ["has already been taken"]} == errors_on(changeset)
    end
  end

  describe "transfer" do
    setup do
      origin_attrs = %{name: "First Account Name", email: "facc@email.com"}
      destination_attrs = %{name: "Second Account Name", email: "sacc@email.com"}

      {:ok, origin_account = %Account{}} = Accounts.create(origin_attrs)
      {:ok, destination_account = %Account{}} = Accounts.create(destination_attrs)

      %{
        origin_account: origin_account,
        destination_account: destination_account,
        original_balance: @default_bonus_balance
      }
    end

    test "transfers value from two accounts when parameters are valid", %{
      origin_account: origin_account,
      destination_account: destination_account,
      original_balance: original_balance
    } do
      transfer_value = 300_00

      assert {:ok, %{origin: origin_account, destination: destination_account}} =
               Accounts.transfer(origin_account, destination_account, transfer_value)

      assert origin_account.balance == original_balance - transfer_value
      assert destination_account.balance == original_balance + transfer_value
    end

    test "fail when accounts are not of %Account{} type", %{
      destination_account: destination_account,
      original_balance: original_balance
    } do
      transfer_value = -500_00

      origin_account = %{}

      assert {:error, %{accounts: "must be of %Account{} type"},
              %{
                origin_account: ^origin_account,
                destination_account: destination_account
              }} = Accounts.transfer(origin_account, destination_account, transfer_value)

      assert destination_account.balance == original_balance
    end

    test "fail when value is not positive or 0", %{
      origin_account: origin_account,
      destination_account: destination_account,
      original_balance: original_balance
    } do
      transfer_value = -500_00

      assert {:error, %{value: "must be an integer greater than or equal to 0"},
              %{
                origin_account: origin_account,
                destination_account: destination_account
              }} = Accounts.transfer(origin_account, destination_account, transfer_value)

      assert origin_account.balance == original_balance
      assert destination_account.balance == original_balance
    end

    test "fail when origin balance is not sufficient", %{
      origin_account: origin_account,
      destination_account: destination_account,
      original_balance: original_balance
    } do
      transfer_value = 5000_00

      assert {:error, %{balance: ["must be greater than or equal to 0"]},
              %{
                origin_account: origin_account,
                destination_account: destination_account
              }} = Accounts.transfer(origin_account, destination_account, transfer_value)

      assert origin_account.balance == original_balance
      assert destination_account.balance == original_balance
    end
  end

  describe "withdraw" do
    setup do
      attrs = %{name: "First Account Name", email: "facc@email.com"}
      {:ok, account = %Account{}} = Accounts.create(attrs)

      %{account: account, original_balance: @default_bonus_balance}
    end

    test "subtract balance from account when parameters are valid", %{
      account: account,
      original_balance: original_balance
    } do
      withdraw_value = 500_00

      assert {:ok, account = %Account{}} = Accounts.withdraw(account, withdraw_value)
      assert account.balance == original_balance - withdraw_value
    end

    test "fail when value is invalid", %{account: account, original_balance: original_balance} do
      withdraw_value = -500_00

      assert {:error, %{value: "must be an integer greater than or equal to 0"},
              %{account: account}} = Accounts.withdraw(account, withdraw_value)

      assert account.balance == original_balance
    end

    test "fail when balance is insufficient", %{
      account: account,
      original_balance: original_balance
    } do
      withdraw_value = 5000_00

      assert {:error, %{balance: ["must be greater than or equal to 0"]},
              %{account: account = %Account{}}} = Accounts.withdraw(account, withdraw_value)

      assert account.balance == original_balance
    end
  end

  describe "fetch" do
    setup do
      {:ok, account = %Account{}} = Accounts.create(@valid_attrs)

      %{account: account}
    end

    test "fetch author when author with given id exists", %{account: account} do
      assert {:ok, account} == Accounts.fetch(account.id)
    end

    test "fail when author with given id doest not exist" do
      assert {:error, :not_found} == Accounts.fetch(Ecto.UUID.generate())
    end

    test "fail when given id is invalid" do
      assert {:error, :invalid_id} == Accounts.fetch(123)
    end
  end
end
