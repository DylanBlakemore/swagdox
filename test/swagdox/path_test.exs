defmodule Swagdox.PathTest do
  use ExUnit.Case

  alias Swagdox.Endpoint
  alias Swagdox.Parameter
  alias Swagdox.Path

  @create_endpoint %Endpoint{
    module: SwagdoxWeb.UserController,
    function: :create,
    docstring: """
    Creates a User.

    API:
      @param user(body), object, "User attributes"

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

  setup do
    path = Path.build(@create_endpoint, @create_route)

    {:ok, path: path}
  end

  describe "build/2" do
    test "returns a Path", %{path: path} do
      assert %Path{} = path
    end

    test "gets the path from the route", %{path: path} do
      assert path.path == "/users"
    end

    test "gets the verb from the route", %{path: path} do
      assert path.verb == :post
    end

    test "gets the description from the endpoint", %{path: path} do
      assert path.description == "Creates a User."
    end

    test "creates the parameters", %{path: path} do
      assert [%Parameter{name: "user"}] = path.parameters
    end
  end

  describe "operation_id/1" do
    test "returns the operation ID", %{path: path} do
      assert Path.operation_id(path) == "SwagdoxWeb.UserController-create"
    end
  end
end
