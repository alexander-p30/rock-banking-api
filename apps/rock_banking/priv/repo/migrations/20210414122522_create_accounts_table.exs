defmodule RockBanking.Repo.Migrations.CreateAccountsTable do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :email, :string, null: false
      add :name, :string, null: false
      add :balance, :integer, null: false, default: 0

      timestamps()
    end

    create unique_index(:accounts, [:email], name: :index_unique_email_on_accounts)
  end
end
