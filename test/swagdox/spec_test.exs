defmodule Swagdox.SpecTest do
  use ExUnit.Case

  alias Swagdox.Path
  alias Swagdox.Spec

  test "init/0" do
    assert %Spec{
             openapi: "3.0.0",
             info: %{
               title: "Swagdox",
               version: "0.1",
               description: _description
             },
             servers: [_server],
             paths: [],
             tags: [],
             components: %{
               schemas: [],
               securitySchemes: []
             }
           } = Spec.init()
  end

  test "set_paths/2" do
    spec = Spec.init()

    paths = [
      %Path{
        verb: "get",
        path: "/users",
        description: "Returns a list of users."
      },
      %Path{
        verb: "post",
        path: "/users",
        description: "Creates a User."
      }
    ]

    assert %Spec{
             paths: ^paths
           } = Spec.set_paths(spec, paths)
  end
end
