defmodule Swagdox.RendererTest do
  use ExUnit.Case

  alias Swagdox.Parameter
  alias Swagdox.Path
  alias Swagdox.Renderer
  alias Swagdox.Spec

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

    spec =
      Spec.init()
      |> Spec.set_paths(paths)

    {:ok, spec: spec}
  end

  describe "render_spec/1" do
    test "renders the info", %{spec: spec} do
      expected_info = %{
        "description" => "A library for generating OpenAPI documentation from Elixir code.",
        "title" => "Swagdox",
        "version" => "0.1"
      }

      assert Renderer.render_spec(spec)["info"] == expected_info
    end

    test "renders the servers", %{spec: spec} do
      expected_servers = [
        %{
          "url" => "http://localhost:4000"
        }
      ]

      assert Renderer.render_spec(spec)["servers"] == expected_servers
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
             } = Renderer.render_spec(spec)["paths"]
    end
  end
end
