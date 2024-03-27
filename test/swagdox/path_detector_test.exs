defmodule Swagdox.PathDetectorTest do
  use ExUnit.Case

  alias Swagdox.Path
  alias Swagdox.PathDetector
  alias SwagdoxWeb.OrderController
  alias SwagdoxWeb.Router, as: WebRouter
  alias SwagdoxWeb.UserController

  defmodule FakeRouter do
  end

  defmodule BrokenRouter do
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
      assert PathDetector.build_paths(FakeRouter) == []
    end

    test "when errors occur" do
      assert PathDetector.build_paths(BrokenRouter) == []
    end

    test "when routes are present" do
      assert PathDetector.build_paths(WebRouter) == [
               %Path{
                 controller: UserController,
                 description: "Returns a User.",
                 function: :show,
                 parameters: [],
                 path: "/users/:id",
                 verb: :get
               },
               %Path{
                 controller: UserController,
                 description: "Creates a User.",
                 function: :create,
                 parameters: [],
                 path: "/users",
                 verb: :post
               },
               %Path{
                 description: "Returns an Order.",
                 path: "/orders/:id",
                 verb: :get,
                 function: :show,
                 controller: OrderController,
                 parameters: []
               },
               %Path{
                 description: "Returns a list of Orders",
                 path: "/orders",
                 verb: :get,
                 function: :index,
                 controller: OrderController,
                 parameters: []
               },
               %Path{
                 description: "Creates an Order.",
                 path: "/orders",
                 verb: :post,
                 function: :create,
                 controller: OrderController,
                 parameters: []
               },
               %Path{
                 description: "Deletes an Order.",
                 path: "/orders/:id",
                 verb: :delete,
                 function: :delete,
                 controller: OrderController,
                 parameters: []
               }
             ]
    end
  end
end
