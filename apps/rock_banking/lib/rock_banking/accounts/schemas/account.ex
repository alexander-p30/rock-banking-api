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

  @spec changeset(
          {map, map}
          | %{
              :__struct__ => atom | %{:__changeset__ => map, optional(any) => any},
              optional(atom) => any
            },
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_length(:name, min: 3)
    |> validate_email_format(:email)
    |> validate_number(:balance, greater_than_or_equal_to: 0, not_equal_to: 1200_00)
    |> unique_constraint(:email, name: :index_unique_email_on_accounts)
  end
end
