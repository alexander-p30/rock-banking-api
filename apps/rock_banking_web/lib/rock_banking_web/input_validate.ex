defmodule RockBankingWeb.InputValidate do
  @moduledoc """
  Validations for input schemas.
  """

  alias RockBanking.ErrorSanitize

  @doc """
  Validates a given changeset. May return {:ok, schema} or {:error, error_map}
  """
  def validate(changeset = %Ecto.Changeset{valid?: true}),
    do: {:ok, Ecto.Changeset.apply_changes(changeset)}

  def validate(changeset = %Ecto.Changeset{valid?: false}),
    do: {:error, ErrorSanitize.to_message_map(changeset)}
end
