defmodule RockBankingWeb.Api.V1.AccountControllerTest do
  use RockBankingWeb.ConnCase, async: true

  alias RockBanking.Accounts

  @valid_attrs %{
    name: "At Least Three",
    email: "valid@email.com",
    email_confirmation: "valid@email.com"
  }

  describe "post /accounts/api/v1" do
    setup do
      %{valid_attrs: @valid_attrs}
    end

    test "success with 200 when all parameters are valid", %{conn: conn, valid_attrs: valid_attrs} do
      %{name: name, email: email} = valid_attrs

      assert %{"name" => ^name, "email" => ^email, "id" => id} =
               conn |> post("api/v1/accounts", valid_attrs) |> json_response(200)

      assert is_binary(id)
      assert String.length(id) == 36
    end

    test "fail with 400 when email confirmation does not match", %{
      conn: conn,
      valid_attrs: valid_attrs
    } do
      valid_attrs = %{valid_attrs | email_confirmation: "another@email.com"}

      assert %{
               "reason" => "bad input",
               "details" => %{
                 "email_confirmation" => ["E-mail and e-mail confirmation must match"]
               }
             } ==
               conn |> post("api/v1/accounts", valid_attrs) |> json_response(400)
    end

    test "fail with 400 when e-mail is invalid", %{
      conn: conn,
      valid_attrs: valid_attrs
    } do
      valid_attrs = %{valid_attrs | email: "invalid.com", email_confirmation: "invalid.com"}

      assert %{
               "reason" => "bad input",
               "details" => %{
                 "email" => ["has invalid format"],
                 "email_confirmation" => ["has invalid format"]
               }
             } ==
               conn |> post("api/v1/accounts", valid_attrs) |> json_response(400)
    end

    test "fail with 400 when name is invalid", %{
      conn: conn,
      valid_attrs: valid_attrs
    } do
      valid_attrs = %{valid_attrs | name: "Ab"}

      assert %{
               "reason" => "bad input",
               "details" => %{
                 "name" => ["should be at least 3 character(s)"]
               }
             } ==
               conn |> post("api/v1/accounts", valid_attrs) |> json_response(400)
    end

    test "fail with 412 when e-mail is taken", %{
      conn: conn,
      valid_attrs: valid_attrs
    } do
      %{name: name, email: email} = valid_attrs

      assert %{"name" => ^name, "email" => ^email, "id" => id} =
               conn |> post("api/v1/accounts", valid_attrs) |> json_response(200)

      assert is_binary(id)
      assert String.length(id) == 36

      assert %{
               "reason" => "bad input",
               "details" => %{
                 "email" => ["has already been taken"]
               }
             } ==
               conn |> post("api/v1/accounts", valid_attrs) |> json_response(412)
    end
  end

  describe "post /accounts/transfer" do
    setup do
      {:ok, origin_account} = Accounts.create(%{name: "Some name", email: "valid@email.com"})

      {:ok, destination_account} =
        Accounts.create(%{name: "Some other name", email: "valid@email2.com"})

      %{
        origin_account_id: origin_account.id,
        destination_account_id: destination_account.id,
        valid_value: 500_00,
        invalid_value: 5000_00
      }
    end

    test "success with 200 when accounts are valid and balance is enough", ctx do
      params = %{
        origin_account_id: ctx.origin_account_id,
        destination_account_id: ctx.destination_account_id,
        value: ctx.valid_value
      }

      assert nil ==
               ctx.conn |> post("api/v1/accounts/transfer", params) |> json_response(200)
    end

    test "fail with 400 when accounts are valid but balance is not enough", ctx do
      params = %{
        origin_account_id: ctx.origin_account_id,
        destination_account_id: ctx.destination_account_id,
        value: ctx.invalid_value
      }

      assert %{
               "details" => %{"balance" => ["must be greater than or equal to 0"]},
               "reason" => "bad input"
             } ==
               ctx.conn |> post("api/v1/accounts/transfer", params) |> json_response(400)
    end

    test "fail with 400 when account does not exist", ctx do
      params = %{
        origin_account_id: Ecto.UUID.generate(),
        destination_account_id: ctx.destination_account_id,
        value: ctx.invalid_value
      }

      assert %{"reason" => "account not found"} ==
               ctx.conn |> post("api/v1/accounts/transfer", params) |> json_response(404)
    end

    test "fail with 400 when provided id is invalid", ctx do
      params = %{
        origin_account_id: 1,
        destination_account_id: ctx.destination_account_id,
        value: ctx.invalid_value
      }

      assert %{"reason" => "invalid id", "details" => %{"id" => "provided id is not valid"}} ==
               ctx.conn |> post("api/v1/accounts/transfer", params) |> json_response(400)
    end
  end

  describe "post /accounts/withdraw" do
    setup do
      {:ok, account} = Accounts.create(%{name: "Some name", email: "valid@email.com"})

      %{account_id: account.id, valid_value: 500_00, invalid_value: 5000_00}
    end

    test "success with 200 when account is valid and balance is enough", ctx do
      params = %{account_id: ctx.account_id, value: ctx.valid_value}

      assert nil ==
               ctx.conn |> post("api/v1/accounts/withdraw", params) |> json_response(200)
    end

    test "fail with 400 when account is valid but balance is not enough", ctx do
      params = %{account_id: ctx.account_id, value: ctx.invalid_value}

      assert %{
               "details" => %{"balance" => ["must be greater than or equal to 0"]},
               "reason" => "bad input"
             } ==
               ctx.conn |> post("api/v1/accounts/withdraw", params) |> json_response(400)
    end

    test "fail with 400 when account does not exist", ctx do
      params = %{account_id: Ecto.UUID.generate(), value: ctx.invalid_value}

      assert %{"reason" => "account not found"} ==
               ctx.conn |> post("api/v1/accounts/withdraw", params) |> json_response(404)
    end

    test "fail with 400 when provided id is invalid", ctx do
      params = %{account_id: 1, value: ctx.invalid_value}

      assert %{"reason" => "invalid id", "details" => %{"id" => "provided id is not valid"}} ==
               ctx.conn |> post("api/v1/accounts/withdraw", params) |> json_response(400)
    end
  end
end
