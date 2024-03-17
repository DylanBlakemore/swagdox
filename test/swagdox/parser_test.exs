defmodule Swagdox.ParserTest do
  use ExUnit.Case

  alias Swagdox.Parser

  test "extract_description/1" do
    docstring = """
    Creates a User.

    API:
      @param user, map, "User attributes"

      @response 201, User, "User created"
      @response 400, "Invalid user attributes"
    """

    assert Parser.extract_description(docstring) == "Creates a User."
  end

  describe "extract_config/1" do
    test "parses a valid line" do
      line = "@param user, map, \"User attributes\""
      assert Parser.extract_config(line) == {:ok, {"@param", "user, map, \"User attributes\""}}
    end

    test "parses an invalid line" do
      line = "user, map, \"User attributes\", required: true"

      assert Parser.extract_config(line) ==
               {:error, "Invalid configuration: user, map, \"User attributes\", required: true"}
    end
  end

  describe "extract_arguments/1" do
    test "parses a line with all arguments" do
      line = "id(query), integer, \"User ID\", required: true"

      assert Parser.extract_arguments(line) ==
               {:ok, [{"id", "query"}, "integer", "User ID", required: true]}
    end

    test "parses a line with optional arguments" do
      line = "id(body), integer, \"User ID\""
      assert Parser.extract_arguments(line) == {:ok, [{"id", "body"}, "integer", "User ID"]}
    end
  end
end
