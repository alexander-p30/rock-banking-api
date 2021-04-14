defmodule RockBanking.ErrorSanitize do
  @moduledoc """
  Sanitize error messages.
  """

  import Ecto.Changeset

  @doc """
  Given an error keyword list from a changeset and a error message mapping, returns a list
  of atom representing error status.
  """
  def to_message_map(changeset) do
    traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
