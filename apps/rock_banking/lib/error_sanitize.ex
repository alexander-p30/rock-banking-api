defmodule RockBanking.ErrorSanitize do
  @moduledoc """
  Sanitize error messages.
  """

  import Ecto.Changeset

  @doc """
  Given an error keyword list from a changeset and a error message mapping, returns a list
  of atom representing error status.
  """
  @spec to_message_map(Ecto.Changeset.t()) :: %{optional(atom) => [String.t()]}
  def to_message_map(changeset = %Ecto.Changeset{valid?: false}) do
    traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  def to_message_map(%Ecto.Changeset{valid?: true}), do: %{}
end
