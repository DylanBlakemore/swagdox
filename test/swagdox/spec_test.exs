defmodule Swagdox.SpecTest do
  use ExUnit.Case

  alias Swagdox.Config
  alias Swagdox.Parameter
  alias Swagdox.Path
  alias Swagdox.Response
  alias Swagdox.Schema
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
             schemas: [],
             security: []
           } = spec()
  end

  setup do
    paths = [
      %Path{
        verb: "get",
        path: "/users",
        description: "Returns a list of users.",
        responses: [Response.build(200, ["User"], "List of users")]
      },
      %Path{
        verb: "post",
        path: "/users",
        description: "Creates a User.",
        responses: [
          Response.build(201, "User", "User created"),
          Response.build(400, "Invalid user attributes")
        ]
      },
      %Path{
        verb: "get",
        path: "/users/{id}",
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

  describe "generate_paths/1" do
    test "generates path instances" do
      assert %{
               paths: [
                 %Swagdox.Path{path: "/users/{id}"},
                 %Swagdox.Path{path: "/users"},
                 %Swagdox.Path{path: "/orders/{id}"},
                 %Swagdox.Path{path: "/orders"},
                 %Swagdox.Path{path: "/orders"},
                 %Swagdox.Path{path: "/orders/{id}"}
               ]
             } = Spec.generate_paths(spec())
    end
  end

  describe "generate_schemas/1" do
    test "generates schemas for all controllers" do
      assert %{
               schemas: [
                 %Schema{
                   module: Swagdox.User,
                   type: "object",
                   properties: [id: :binary_id, name: :string, email: :string],
                   required: []
                 },
                 %Schema{
                   module: Swagdox.Order,
                   type: "object",
                   properties: [id: :binary_id, item: :string, number: :integer],
                   required: []
                 }
               ]
             } = Spec.generate_schemas(spec())
    end
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

    test "renders the schemas", %{spec: spec} do
      assert %{
               "components" => %{
                 "schemas" => %{
                   "User" => %{
                     "type" => "object",
                     "properties" => %{
                       "id" => %{"type" => "string"},
                       "name" => %{"type" => "string"},
                       "email" => %{"type" => "string"}
                     }
                   },
                   "Order" => %{
                     "type" => "object",
                     "properties" => %{
                       "id" => %{"type" => "string"},
                       "item" => %{"type" => "string"},
                       "number" => %{"type" => "integer"}
                     }
                   }
                 }
               }
             } = spec |> Spec.generate_schemas() |> Spec.render()
    end

    test "renders the paths", %{spec: spec} do
      assert %{
               "/users" => %{
                 "get" => %{
                   "description" => "Returns a list of users.",
                   "responses" => %{
                     "200" => %{
                       "content" => %{
                         "application/json" => %{
                           "schema" => %{
                             "type" => "array",
                             "items" => %{"$ref" => "#/components/schemas/User"}
                           }
                         }
                       },
                       "description" => "List of users"
                     }
                   }
                 },
                 "post" => %{
                   "description" => "Creates a User.",
                   "responses" => %{
                     "201" => %{
                       "content" => %{
                         "application/json" => %{
                           "schema" => %{"$ref" => "#/components/schemas/User"}
                         }
                       },
                       "description" => "User created"
                     },
                     "400" => %{"description" => "Invalid user attributes"}
                   }
                 }
               },
               "/users/{id}" => %{
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
                   ],
                   "responses" => %{}
                 }
               },
               "/orders" => %{
                 "get" => %{
                   "description" => "Returns a list of orders.",
                   "responses" => %{}
                 }
               }
             } = Spec.render(spec)["paths"]
    end
  end
end
