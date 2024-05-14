defmodule Swagdox.ParserTest do
  use ExUnit.Case

  alias Swagdox.Parser

  describe "extract_name/1" do
    test "extracts the name from a docstring" do
      docstring = """
      Creates a User.

      [Swagdox] Schema:
        @name User
      """

      assert Parser.extract_name(docstring) == "@name User"
    end

    test "errors with no name" do
      docstring = """
      Creates a User.

      [Swagdox] Schema:
      """

      assert_raise ArgumentError, fn ->
        Parser.extract_name(docstring)
      end
    end

    test "errors with multiple names" do
      docstring = """
      Creates a User.

      [Swagdox] Schema:
        @name User
        @name User
      """

      assert_raise ArgumentError, fn ->
        Parser.extract_name(docstring)
      end
    end
  end

  test "extract_properties/1" do
    docstring = """
    Creates a User.

    [Swagdox] Schema:
      @property id, integer, "User id"
      @property name, string, "User name"
      @property email, string, "User email"
    """

    assert Parser.extract_properties(docstring) ==
             [
               "@property id, integer, \"User id\"",
               "@property name, string, \"User name\"",
               "@property email, string, \"User email\""
             ]
  end

  test "extract_description/1" do
    docstring = """
    Creates a User.

    [Swagdox] API:
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

      [Swagdox] API:
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

      [Swagdox] API:
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

  describe "extract_module_doc/1" do
    test "extracts the module docstring from a module" do
      module = Swagdox.User

      assert Parser.extract_module_doc(module) ==
               """
               Represents a user.

               [Swagdox] Schema:
                 @name User

                 @property id, integer, "User id"
                 @property name, string, "User name"
                 @property email, string, "User email"
                 @property orders, [OrderName], "User orders"
               """
    end

    test "returns an empty string if no docstring is found" do
      module = Swagdox.Router

      assert Parser.extract_module_doc(module) == ""
    end
  end

  describe "parse_definition/1" do
    test "name" do
      line = "@name User"

      assert Parser.parse_definition(line) ==
               {:name, "User"}
    end

    test "property" do
      line = "@property id, integer, \"User id\""

      assert Parser.parse_definition(line) ==
               {:property, ["id", "integer", "User id"]}
    end

    test "array properties" do
      line = "@property user, [User], \"User object\""

      assert Parser.parse_definition(line) ==
               {:property, ["user", ["User"], "User object"]}
    end

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
