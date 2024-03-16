defmodule Swagdox.ExtractorTest do
  use ExUnit.Case

  alias Swagdox.Extractor
  alias SwagdoxWeb.UserController

  describe "extract/1" do
    test "successful extraction only extracts for functions with API specification" do
      {:ok, extractions} = Extractor.extract(UserController)

      assert length(extractions) == 2
    end

    test "successful extraction extracts the description and spec" do
      {:ok, [{function, description, spec}, _show]} = Extractor.extract(UserController)

      assert function == :create
      assert description == "Creates a User."

      assert spec == """
               @path POST /users
               @param user, map, required, "User attributes"

               @response 201, "User created"
               @response 400, "Invalid user attributes"
             """
    end
  end
end
