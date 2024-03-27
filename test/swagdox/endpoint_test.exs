defmodule Swagdox.EndpointTest do
  use ExUnit.Case

  alias Swagdox.Endpoint
  alias SwagdoxWeb.UserController

  describe "extract_all/1" do
    test "successful extraction only extracts for functions with API specification" do
      {:ok, endpoints} = Endpoint.extract_all(UserController)

      assert length(endpoints) == 2
    end

    test "successful extraction extracts the description and spec" do
      {:ok, [%Endpoint{module: UserController, function: function, docstring: docstring}, _show]} =
        Endpoint.extract_all(UserController)

      assert function == :create

      assert docstring == """
             Creates a User.

             API:
               @param user(body), map, required, "User attributes"

               @response 201, User, "User created"
               @response 400, "Invalid user attributes"
             """
    end

    test "module not found" do
      {:error, reason} = Endpoint.extract_all(NonExistentModule)

      assert reason == "Module 'NonExistentModule' not found"
    end
  end
end
