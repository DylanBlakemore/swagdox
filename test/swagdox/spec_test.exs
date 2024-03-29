defmodule Swagdox.SpecTest do
  use ExUnit.Case

  alias Swagdox.Config
  alias Swagdox.Parameter
  alias Swagdox.Path
  alias Swagdox.Spec

  # credo:disable-for-next-line
  def spec, do: Spec.init(Config.init())

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
           } = spec()
  end

  setup do
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
      },
      %Path{
        verb: "get",
        path: "/users/:id",
        description: "Returns a User.",
        parameters: [
          %Parameter{
            name: "id",
            in: "query",
            description: "User ID",
            required: true,
            schema: %{
              type: "string"
            }
          }
        ]
      },
      %Path{
        verb: "get",
        path: "/orders",
        description: "Returns a list of orders."
      }
    ]

    spec = %{spec() | paths: paths}

    {:ok, spec: spec}
  end

  describe "render/1" do
    test "renders the info", %{spec: spec} do
      expected_info = %{
        "description" => "A library for generating OpenAPI documentation from Elixir code.",
        "title" => "Swagdox",
        "version" => "0.1"
      }

      assert Spec.render(spec)["info"] == expected_info
    end

    test "renders the servers", %{spec: spec} do
      expected_servers = [
        %{
          "url" => "http://localhost:4000"
        }
      ]

      assert Spec.render(spec)["servers"] == expected_servers
    end

    test "generate_paths/1" do
      assert %{
               paths: [
                 %Swagdox.Path{path: "/users/:id"},
                 %Swagdox.Path{path: "/users"},
                 %Swagdox.Path{path: "/orders/:id"},
                 %Swagdox.Path{path: "/orders"},
                 %Swagdox.Path{path: "/orders"},
                 %Swagdox.Path{path: "/orders/:id"}
               ]
             } = Spec.generate_paths(spec())
    end

    test "renders the paths", %{spec: spec} do
      assert %{
               "/users" => %{
                 "get" => %{
                   "description" => "Returns a list of users."
                 },
                 "post" => %{
                   "description" => "Creates a User."
                 }
               },
               "/users/:id" => %{
                 "get" => %{
                   "description" => "Returns a User.",
                   "parameters" => [
                     %{
                       "description" => "User ID",
                       "in" => "query",
                       "name" => "id",
                       "required" => true,
                       "schema" => %{
                         "type" => "string"
                       }
                     }
                   ]
                 }
               },
               "/orders" => %{
                 "get" => %{
                   "description" => "Returns a list of orders."
                 }
               }
             } = Spec.render(spec)["paths"]
    end
  end
end
