defmodule RockBanking.Changesets do
  @moduledoc """
  Changeset validations for domain.
  """

  import Ecto.Changeset

  @email_regex ~r/^[A-Za-z0-9\._%+\-+']+@[A-Za-z0-9\.\-]+\.[A-Za-z]{2,4}$/

  @doc """
  Validates format of a given field in a changeset according to a regex match.
  """
  @spec validate_email_format(Ecto.Changeset.t(), atom) :: Ecto.Changeset.t()
  def validate_email_format(changeset, field) do
    validate_format(changeset, field, @email_regex)
  end
end
