defmodule SwagdoxWeb.Router do
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
      }
    ]
  end
end
