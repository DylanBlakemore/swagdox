defmodule SwagdoxWeb.Router do
  @moduledoc """
  Routes for our SwagdoxWeb application.
  """
  @type route :: %{
          path: String.t(),
          metadata: map(),
          plug: module(),
          plug_opts: atom(),
          helper: String.t(),
          verb: atom()
        }

  @spec __routes__() :: list(route())
  def __routes__() do
    [
      %{
        path: "/users/:id",
        metadata: %{},
        plug: SwagdoxWeb.UserController,
        plug_opts: :show,
        helper: "user_path",
        verb: :get
      },
      %{
        path: "/users",
        metadata: %{},
        plug: SwagdoxWeb.UserController,
        plug_opts: :index,
        helper: "user_path",
        verb: :get
      },
      %{
        path: "/users",
        metadata: %{},
        plug: SwagdoxWeb.UserController,
        plug_opts: :create,
        helper: "user_path",
        verb: :post
      },
      %{
        path: "/users/:id",
        metadata: %{},
        plug: SwagdoxWeb.UserController,
        plug_opts: :update,
        helper: "user_path",
        verb: :put
      },
      %{
        path: "/users/:id",
        metadata: %{},
        plug: SwagdoxWeb.UserController,
        plug_opts: :delete,
        helper: "user_path",
        verb: :delete
      },
      %{
        path: "/orders/:id",
        metadata: %{},
        plug: SwagdoxWeb.OrderController,
        plug_opts: :show,
        helper: "order_path",
        verb: :get
      },
      %{
        path: "/orders",
        metadata: %{},
        plug: SwagdoxWeb.OrderController,
        plug_opts: :index,
        helper: "order_path",
        verb: :get
      },
      %{
        path: "/orders",
        metadata: %{},
        plug: SwagdoxWeb.OrderController,
        plug_opts: :create,
        helper: "order_path",
        verb: :post
      },
      %{
        path: "/orders/:id",
        metadata: %{},
        plug: SwagdoxWeb.OrderController,
        plug_opts: :update,
        helper: "order_path",
        verb: :put
      },
      %{
        path: "/orders/:id",
        metadata: %{},
        plug: SwagdoxWeb.OrderController,
        plug_opts: :delete,
        helper: "order_path",
        verb: :delete
      }
    ]
  end
end
