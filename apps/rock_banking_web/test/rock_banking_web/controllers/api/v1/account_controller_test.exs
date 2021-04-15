defmodule RockBankingWeb.Api.V1.AccountControllerTest do
  use RockBankingWeb.ConnCase, async: true

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
end
