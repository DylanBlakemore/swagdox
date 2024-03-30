defmodule Swagdox.PathTest do
  use ExUnit.Case

  alias Swagdox.Endpoint
  alias Swagdox.Parameter
  alias Swagdox.Path
  alias Swagdox.Response

  @create_endpoint %Endpoint{
    module: SwagdoxWeb.UserController,
    function: :create,
    docstring: """
    Creates a User.

    API:
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

    API:
      @param id(path), integer, "User ID", required: true

      @response 200, User, "User found"
      @response 403, "User not authorized"
      @response 404, "User not found"
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
  end

  describe "operation_id/1" do
    test "returns the operation ID", %{create: create} do
      assert Path.operation_id(create) == "SwagdoxWeb.UserController-create"
    end
  end
end
