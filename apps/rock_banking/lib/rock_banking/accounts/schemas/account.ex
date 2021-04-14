defmodule RockBanking.Accounts.Schemas.Account do
  @moduledoc """
  Database schema for baking accounts.
  """

  use Ecto.Schema

  import Ecto.Changeset
  import RockBanking.Changesets

  @required_fields [:name, :email]
  @optional_fields [:balance]

  @derive {Jason.Encoder, except: [:__meta__]}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "accounts" do
    field :name, :string
    field :email, :string
    field :balance, :integer, default: 0

    timestamps()
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_length(:name, min: 3)
    |> validate_email_format(:email)
    |> unique_constraint(:email, name: :index_unique_email_on_accounts)
  end
end
