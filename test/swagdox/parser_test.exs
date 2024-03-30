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

  describe "extract_params/1" do
    test "extracts parameters from a docstring" do
      docstring = """
      Creates a User.

      API:
        @param user, map, "User attributes"
        @param id, integer, "User ID"

        @response 201, User, "User created"
      """

      assert Parser.extract_params(docstring) ==
               ["@param user, map, \"User attributes\"", "@param id, integer, \"User ID\""]
    end
  end

  describe "extract_responses/1" do
    test "extracts responses from a docstring" do
      docstring = """
      Creates a User.

      API:
        @param user, map, "User attributes"

        @response 201, User, "User created"
        @response 400, "Invalid user attributes"
      """

      assert Parser.extract_responses(docstring) ==
               [
                 "@response 201, User, \"User created\"",
                 "@response 400, \"Invalid user attributes\""
               ]
    end
  end

  describe "parse_definition/1" do
    test "list types" do
      line = "@response 200, [User], \"List of users\""

      assert Parser.parse_definition(line) ==
               {:response, [200, ["User"], "List of users"]}
    end

    test "response" do
      line = "@response 201, User, \"User created\""

      assert Parser.parse_definition(line) ==
               {:response, [201, "User", "User created"]}
    end

    test "response with options" do
      line = "@response 201, User, \"User created\", properties: [id, name]"

      assert Parser.parse_definition(line) ==
               {:response, [201, "User", "User created", [properties: ["id", "name"]]]}
    end

    test "response without a status" do
      line = "@response User, \"User created\""

      assert {:error, _reason} = Parser.parse_definition(line)
    end

    test "with a non-numeric status" do
      line = "@response hello, User, \"User created\""

      assert {:error, _reason} = Parser.parse_definition(line)
    end

    test "parameter without a location" do
      line = "@param user, map, \"User attributes\""

      assert {:error, _reason} = Parser.parse_definition(line)
    end

    test "parameter with an invalid location" do
      line = "@param user(invalid), map, \"User attributes\""

      assert {:error, _reason} = Parser.parse_definition(line)
    end

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
      line = "@param user(body), map, %{hello: :world}"

      assert Parser.parse_definition(line) ==
               {:error, "Unable to parse node: {:%{}, [line: 1], [hello: :world]}"}
    end

    test "parses a line with all arguments" do
      line = "@param id(query), integer, \"User ID\", required: true"

      assert Parser.parse_definition(line) ==
               {:param, [{"id", "query"}, "integer", "User ID", [required: true]]}
    end

    test "parses a line with optional arguments" do
      line = "@param id(body), integer, \"User ID\""

      assert Parser.parse_definition(line) ==
               {:param, [{"id", "body"}, "integer", "User ID"]}
    end

    test "string-value kwarg" do
      line = "@param id(body), integer, \"User ID\", format: password"

      assert Parser.parse_definition(line) ==
               {:param, [{"id", "body"}, "integer", "User ID", [format: "password"]]}
    end

    test "complex types" do
      line = "@param id(body), array(integer), \"User ID\""

      assert Parser.parse_definition(line) ==
               {:param, [{"id", "body"}, {"array", "integer"}, "User ID"]}
    end
  end
end
