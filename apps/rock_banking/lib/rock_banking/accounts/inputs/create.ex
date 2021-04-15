defmodule RockBanking.Accounts.Inputs.Create do
  @moduledoc """
  Input schema for account fields input validation.
  """

  use Ecto.Schema

  import Ecto.Changeset
  import RockBanking.Changesets

  @required_fields [:name, :email, :email_confirmation]
  @optional_fields [:balance]

  @primary_key false
  embedded_schema do
    field :name, :string
    field :email, :string
    field :email_confirmation, :string
    field :balance, :integer
  end

  defdelegate fetch(struct, key), to: Map

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_length(:name, min: 3)
    |> validate_email_format(:email)
    |> validate_email_format(:email_confirmation)
    |> validate_number(:balance, greater_than_or_equal_to: 0)
    |> validate_field_confirmation(:email, :email_confirmation)
  end

  defp validate_field_confirmation(changeset, field, confirmation_field) do
    if changeset.changes[field] == changeset.changes[confirmation_field] do
      changeset
    else
      add_error(changeset, :email_confirmation, "E-mail and e-mail confirmation must match")
    end
  end
end
