defmodule Swagdox.EndpointTest do
  use ExUnit.Case

  alias Swagdox.Endpoint
  alias Swagdox.Parameter
  alias Swagdox.Response
  alias Swagdox.Security
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

             [Swagdox] API:
               @param user(body), User, "User attributes", required: true

               @response 201, User, "User created"
               @response 400, "Invalid user attributes"

               @security BasicAuth, [admin]

               @tags users, creation
             """
    end

    test "module not found" do
      {:error, reason} = Endpoint.extract_all(NonExistentModule)

      assert reason == "Module 'NonExistentModule' not found"
    end
  end

  describe "parameters/1" do
    test "returns the parameters for the endpoint" do
      endpoint = %Endpoint{
        module: UserController,
        function: :create,
        docstring: """
        Creates a User.

        [Swagdox] API:
          @param user(body), object, "User attributes"
          @param id(path), integer, "User ID", required: true

          @response 201, User, "User created"
          @response 400, "Invalid user attributes"
        """
      }

      parameters = Endpoint.parameters(endpoint)

      assert [
               %Parameter{
                 name: "id",
                 required: true
               }
             ] = parameters
    end

    test "when a parameter has an error" do
      endpoint = %Endpoint{
        module: UserController,
        function: :create,
        docstring: """
        Creates a User.

        [Swagdox] API:
          @param user(body), object, "User attributes"
          @param id(path), integer, "User ID", required: true
          @param invalid, map, "Invalid parameter"
        """
      }

      assert_raise ArgumentError, fn ->
        Endpoint.parameters(endpoint)
      end
    end
  end

  describe "tags/1" do
    test "returns the tags for the endpoint" do
      endpoint = %Endpoint{
        module: UserController,
        function: :create,
        docstring: """
        Creates a User.

        [Swagdox] API:
          @param user(body), object, "User attributes"
          @param id(path), integer, "User ID", required: true

          @response 201, User, "User created"
          @response 400, "Invalid user attributes"

          @tags users, creation
        """
      }

      tags = Endpoint.tags(endpoint)

      assert ["users", "creation"] = tags
    end
  end

  describe "responses/1" do
    test "returns the responses for the endpoint" do
      endpoint = %Endpoint{
        module: UserController,
        function: :create,
        docstring: """
        Creates a User.

        [Swagdox] API:
          @param user(body), object, "User attributes"
          @param id(path), integer, "User ID", required: true

          @response 201, User, "User created", content_type: "application/json"
          @response 400, "Invalid user attributes"
        """
      }

      responses = Endpoint.responses(endpoint)

      assert [
               %Response{
                 status: 201,
                 description: "User created",
                 options: [content_type: "application/json"]
               },
               %Response{
                 status: 400,
                 description: "Invalid user attributes"
               }
             ] = responses
    end
  end

  describe "security/1" do
    test "returns the authorization for the endpoint" do
      endpoint = %Endpoint{
        module: UserController,
        function: :create,
        docstring: """
        Creates a User.

        [Swagdox] API:
          @param user(body), object, "User attributes"
          @param id(path), integer, "User ID", required: true

          @response 201, User, "User created", content_type: "application/json"
          @response 400, "Invalid user attributes"

          @security BasicAuth
          @security BearerAuth, [admin, write]
        """
      }

      security = Endpoint.security(endpoint)

      assert [
               %Security{
                 name: "BasicAuth"
               },
               %Security{
                 name: "BearerAuth",
                 scopes: ["admin", "write"]
               }
             ] = security
    end
  end

  describe "request_body/1" do
    test "returns the request body parameter when present" do
      endpoint = %Endpoint{
        module: UserController,
        function: :create,
        docstring: """
        Creates a User.

        [Swagdox] API:
          @param user(body), User, "User attributes", required: true

          @response 201, User, "User created"
        """
      }

      request_body = Endpoint.request_body(endpoint)

      assert [
               %Parameter{
                 name: "user",
                 in: "body",
                 type: "User",
                 description: "User attributes",
                 required: true
               }
             ] = request_body
    end

    test "returns empty list when no body parameter is present" do
      endpoint = %Endpoint{
        module: UserController,
        function: :show,
        docstring: """
        Returns a User.

        [Swagdox] API:
          @param id(path), integer, "User ID", required: true

          @response 200, User, "User found"
        """
      }

      assert Endpoint.request_body(endpoint) == []
    end

    test "returns the request body when header and body parameters are both present" do
      endpoint = %Endpoint{
        module: UserController,
        function: :create,
        docstring: """
        Creates a User.

        [Swagdox] API:
          @param organisation(header), string, "The organisation UUID", required: true
          @param user(body), User, "User attributes", required: true

          @response 201, User, "User created"
        """
      }

      request_body = Endpoint.request_body(endpoint)

      assert [
               %Parameter{
                 name: "user",
                 in: "body",
                 type: "User",
                 required: true
               }
             ] = request_body
    end

    test "returns all body parameters when multiple body parameters are present" do
      endpoint = %Endpoint{
        module: UserController,
        function: :create,
        docstring: """
        Creates a User.

        [Swagdox] API:
          @param user(body), User, "User attributes", required: true
          @param metadata(body), object, "Additional metadata"

          @response 201, User, "User created"
        """
      }

      request_body = Endpoint.request_body(endpoint)

      assert [
               %Parameter{
                 name: "user",
                 in: "body",
                 type: "User",
                 required: true
               },
               %Parameter{
                 name: "metadata",
                 in: "body",
                 type: "object"
               }
             ] = request_body
    end
  end
end
