defmodule RockBanking.ErrorSanitize do
  @moduledoc """
  Sanitize error messages.
  """

  @doc """
  Given an error keyword list from a changeset and a error message mapping, returns a list
  of atom representing error status.
  """
  def to_status_list(errors, error_messages = %{}) do
    errors
    |> Enum.map(fn {field, error_details} ->
      {_message, failed_validation} = error_details

      if error_messages[field],
        do: error_messages[field][failed_validation[:kind]] || :"#{field}_unknown_error",
        else: :"unknown_field_#{field}"
    end)
  end
end
