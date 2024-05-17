defmodule Swagdox.SpecTest do
  use ExUnit.Case

  alias Swagdox.Authorization
  alias Swagdox.Config
  alias Swagdox.Parameter
  alias Swagdox.Path
  alias Swagdox.Response
  alias Swagdox.Schema
  alias Swagdox.Security
  alias Swagdox.Spec

  @config %Config{
    version: "0.1",
    title: "Swagdox",
    description: "A library for generating OpenAPI documentation from Elixir code.",
    servers: ["http://localhost:4000"],
    router: SwagdoxWeb.Router,
    openapi_version: "3.0.0",
    output: "swagger.json",
    format: "json"
  }

  # credo:disable-for-next-line
  def spec, do: Spec.init(@config)

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
        responses: [Response.build(200, ["User"], "List of users")],
        security: [
          %Security{name: "BasicAuth", scopes: []}
        ]
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
                   module: Swagdox.Order,
                   type: "object",
                   properties: [{"item", "string"}, {"number", "integer"}],
                   required: []
                 },
                 %Schema{
                   module: Swagdox.User,
                   type: "object",
                   properties: [
                     {"id", "integer"},
                     {"name", "string"},
                     {"email", "string"},
                     {"orders", ["OrderName"]}
                   ],
                   required: []
                 }
               ]
             } = Spec.generate_schemas(spec())
    end
  end

  describe "generate_security_schemes/1" do
    test "generates security schemes for the router" do
      assert %{
               security: [
                 %Authorization{
                   type: "http",
                   name: "BasicAuth",
                   description: "Basic http authentication",
                   properties: %{"scheme" => "basic"}
                 },
                 %Authorization{
                   type: "apiKey",
                   name: "ApiKey",
                   description: "API key authentication",
                   properties: %{"in" => "header", "name" => "X-API-Key"}
                 }
               ]
             } = Spec.generate_security_schemes(spec())
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

    test "renders the security schemes", %{spec: spec} do
      assert %{
               "components" => %{
                 "securitySchemes" => %{
                   "ApiKey" => %{
                     "description" => "API key authentication",
                     "in" => "header",
                     "name" => "X-API-Key",
                     "type" => "apiKey"
                   },
                   "BasicAuth" => %{
                     "description" => "Basic http authentication",
                     "scheme" => "basic",
                     "type" => "http"
                   }
                 }
               }
             } = spec |> Spec.generate_security_schemes() |> Spec.render()
    end

    test "renders the schemas", %{spec: spec} do
      assert %{
               "components" => %{
                 "schemas" => %{
                   "User" => %{
                     "type" => "object",
                     "properties" => %{
                       "id" => %{"type" => "integer"},
                       "name" => %{"type" => "string"},
                       "email" => %{"type" => "string"}
                     }
                   },
                   "OrderName" => %{
                     "type" => "object",
                     "properties" => %{
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
                   "security" => [%{"BasicAuth" => []}],
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
                   "security" => [],
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
                   "security" => [],
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
                   "security" => [],
                   "description" => "Returns a list of orders.",
                   "responses" => %{}
                 }
               }
             } = Spec.render(spec)["paths"]
    end
  end
end
