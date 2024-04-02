defmodule Swagdox.PathBuilderTest do
  use ExUnit.Case

  alias Swagdox.Path
  alias Swagdox.PathBuilder
  alias SwagdoxWeb.OrderController
  alias SwagdoxWeb.Router, as: WebRouter
  alias SwagdoxWeb.UserController

  defmodule FakeRouter do
  end

  defmodule BrokenRouter do
    # credo:disable-for-next-line
    def __routes__ do
      [
        %{
          path: "/users/:id",
          plug: FakeController,
          plug_opts: nil,
          verb: :get
        }
      ]
    end
  end

  describe "build_paths/1" do
    test "when no routes are present on the module" do
      assert PathBuilder.build_paths(FakeRouter) == []
    end

    test "when errors occur" do
      assert PathBuilder.build_paths(BrokenRouter) == []
    end

    test "when routes are present" do
      assert [
               %Path{
                 controller: UserController,
                 description: "Returns a User.",
                 verb: :get
               },
               %Path{
                 controller: UserController,
                 description: "Creates a User.",
                 verb: :post
               },
               %Path{
                 description: "Returns an Order.",
                 verb: :get,
                 controller: OrderController
               },
               %Path{
                 description: "Returns a list of Orders",
                 verb: :get,
                 controller: OrderController
               },
               %Path{
                 description: "Creates an Order.",
                 verb: :post,
                 controller: OrderController
               },
               %Path{
                 description: "Deletes an Order.",
                 verb: :delete,
                 controller: OrderController
               }
             ] = PathBuilder.build_paths(WebRouter)
    end
  end
end
