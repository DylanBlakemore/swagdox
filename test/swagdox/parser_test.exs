defmodule Swagdox.ParserTest do
  use ExUnit.Case

  alias Swagdox.Parser

  test "extract_description/1" do
    docstring = """
    Creates a User.

    API:
      @param user, map, required, "User attributes"

      @response 201, User, "User created"
      @response 400, "Invalid user attributes"
    """

    assert Parser.extract_description(docstring) == "Creates a User."
  end

  describe "extract_arguments/1" do
    test "parses a line with all arguments" do
      line = "id(query), integer, required, \"User ID\""

      assert Parser.extract_arguments(line) ==
               {:ok, [{"id", "query"}, "integer", "required", "User ID"]}
    end

    test "parses a line with optional arguments" do
      line = "id(body), integer, \"User ID\""
      assert Parser.extract_arguments(line) == {:ok, [{"id", "body"}, "integer", "User ID"]}
    end
  end
end
