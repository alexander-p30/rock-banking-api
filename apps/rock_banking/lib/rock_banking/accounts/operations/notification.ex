defmodule RockBanking.Accounts.Operations.Notification do
  @moduledoc """
  Placeholder for a notification module.
  """

  alias RockBanking.Accounts.Schemas.Account

  @available_actions [:withdraw, :transfer]

  @doc """
  Placeholder function for sending emails.
  """
  @spec send_email(%Account{}, :transfer | :withdraw) :: %Account{}
  def send_email(account = %Account{}, action) when action in @available_actions do
    account
  end
end
