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

  describe "parse_definition/1" do
    test "invalid ast" do
      line = "%{hello: :world}"

      assert Parser.parse_definition(line) ==
               {:error, "Invalid syntax"}
    end

    test "invalid syntax" do
      line = ".> ("

      assert Parser.parse_definition(line) ==
               {:error, "Unable to parse line: .> ("}
    end

    test "node error" do
      line = "@param user, map, %{hello: :world}"

      assert Parser.parse_definition(line) ==
               {:error, "Unable to parse node: {:%{}, [line: 1], [hello: :world]}"}
    end

    test "parses a line with all arguments" do
      line = "@param id(query), integer, \"User ID\", required: true"

      assert Parser.parse_definition(line) ==
               {:ok, {:param, [{"id", "query"}, "integer", "User ID", [required: true]]}}
    end

    test "parses a line with optional arguments" do
      line = "@param id(body), integer, \"User ID\""

      assert Parser.parse_definition(line) ==
               {:ok, {:param, [{"id", "body"}, "integer", "User ID"]}}
    end

    test "string-value kwarg" do
      line = "@param id(body), integer, \"User ID\", format: password"

      assert Parser.parse_definition(line) ==
               {:ok, {:param, [{"id", "body"}, "integer", "User ID", [format: "password"]]}}
    end

    test "complex types" do
      line = "@param id(body), array(integer), \"User ID\""

      assert Parser.parse_definition(line) ==
               {:ok, {:param, [{"id", "body"}, {"array", "integer"}, "User ID"]}}
    end
  end
end
