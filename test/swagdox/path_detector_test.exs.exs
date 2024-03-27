defmodule Swagdox.PathDetectorTest do
  use ExUnit.Case

  alias Swagdox.Path
  alias Swagdox.PathDetector
  alias SwagdoxWeb.OrderController
  alias SwagdoxWeb.Router, as: WebRouter
  alias SwagdoxWeb.UserController

  test "build_paths/1" do
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
