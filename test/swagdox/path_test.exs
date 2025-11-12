defmodule Swagdox.PathTest do
  use ExUnit.Case

  alias Swagdox.Endpoint
  alias Swagdox.Parameter
  alias Swagdox.Path
  alias Swagdox.Response
  alias Swagdox.Security

  @create_endpoint %Endpoint{
    module: SwagdoxWeb.UserController,
    function: :create,
    docstring: """
    Creates a User.

    [Swagdox] API:
      @param user(query), object, "User attributes"

      @response 201, User, "User created"
      @response 400, "Invalid user attributes"
    """
  }

  @create_route %{
    path: "/users",
    plug: SwagdoxWeb.UserController,
    plug_opts: :create,
    verb: :post
  }

  @show_endpoint %Endpoint{
    module: SwagdoxWeb.UserController,
    function: :show,
    docstring: """
    Returns a User.

    [Swagdox] API:
      @param id(path), integer, "User ID", required: true

      @response 200, User, "User found"
      @response 403, "User not authorized"
      @response 404, "User not found"

      @security BasicAuth
      @security ApiKey, [read, write]

      @tags users
    """
  }

  @show_route %{
    path: "/users/:id",
    plug: SwagdoxWeb.UserController,
    plug_opts: :show,
    verb: :get
  }

  setup do
    create = Path.build(@create_endpoint, @create_route)
    show = Path.build(@show_endpoint, @show_route)

    {:ok, create: create, show: show}
  end

  describe "build/2" do
    test "returns a Path", %{create: create} do
      assert %Path{} = create
    end

    test "gets the path from the route", %{create: create} do
      assert create.path == "/users"
    end

    test "gets the verb from the route", %{create: create} do
      assert create.verb == :post
    end

    test "gets the description from the endpoint", %{create: create} do
      assert create.description == "Creates a User."
    end

    test "creates the parameters", %{create: create} do
      assert [%Parameter{name: "user"}] = create.parameters
    end

    test "creates the responses", %{create: create} do
      assert [%Response{status: 201}, %Response{status: 400}] = create.responses
    end

    test "adjusts the path to obey the OpenAPI spec", %{show: show} do
      assert show.path == "/users/{id}"
    end

    test "extracts the tags from the docstring", %{show: show} do
      assert show.tags == ["users"]
    end

    test "creates the security options", %{show: show} do
      assert show.security == [
               %Security{name: "BasicAuth", scopes: []},
               %Security{name: "ApiKey", scopes: ["read", "write"]}
             ]
    end

    test "creates the request body when body parameter is present" do
      endpoint = %Endpoint{
        module: SwagdoxWeb.UserController,
        function: :create,
        docstring: """
        Creates a User.

        [Swagdox] API:
          @param user(body), User, "User attributes", required: true

          @response 201, User, "User created"
        """
      }

      route = %{
        path: "/users",
        plug: SwagdoxWeb.UserController,
        plug_opts: :create,
        verb: :post
      }

      path = Path.build(endpoint, route)

      assert [
               %Parameter{
                 name: "user",
                 in: "body",
                 type: "User",
                 required: true
               }
             ] = path.request_body
    end

    test "sets request_body to empty list when no body parameter is present", %{show: show} do
      assert show.request_body == []
    end

    test "creates both parameters and request_body when header and body parameters are present" do
      endpoint = %Endpoint{
        module: SwagdoxWeb.UserController,
        function: :create,
        docstring: """
        Creates a User.

        [Swagdox] API:
          @param organisation(header), string, "The organisation UUID", required: true
          @param user(body), User, "User attributes", required: true

          @response 201, User, "User created"
        """
      }

      route = %{
        path: "/users",
        plug: SwagdoxWeb.UserController,
        plug_opts: :create,
        verb: :post
      }

      path = Path.build(endpoint, route)

      assert [%Parameter{name: "organisation", in: "header"}] = path.parameters
      assert [%Parameter{name: "user", in: "body"}] = path.request_body
    end

    test "creates request_body with multiple body parameters" do
      endpoint = %Endpoint{
        module: SwagdoxWeb.UserController,
        function: :create,
        docstring: """
        Creates a User.

        [Swagdox] API:
          @param user(body), User, "User attributes", required: true
          @param metadata(body), object, "Additional metadata"

          @response 201, User, "User created"
        """
      }

      route = %{
        path: "/users",
        plug: SwagdoxWeb.UserController,
        plug_opts: :create,
        verb: :post
      }

      path = Path.build(endpoint, route)

      assert [
               %Parameter{name: "user", in: "body", required: true},
               %Parameter{name: "metadata", in: "body"}
             ] = path.request_body
    end
  end

  describe "operation_id/1" do
    test "returns the operation ID", %{create: create} do
      assert Path.operation_id(create) == "SwagdoxWeb.UserController-create"
    end
  end
end
