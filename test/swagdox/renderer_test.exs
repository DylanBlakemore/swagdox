defmodule Swagdox.RendererTest do
  use ExUnit.Case

  alias Swagdox.Path
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
        description: "Returns a User."
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

      assert Swagdox.Renderer.render_spec(spec)["info"] == expected_info
    end

    test "renders the servers", %{spec: spec} do
      expected_servers = [
        %{
          "url" => "http://localhost:4000"
        }
      ]

      assert Swagdox.Renderer.render_spec(spec)["servers"] == expected_servers
    end

    test "renders the paths", %{spec: spec} do
      expected_paths = %{
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
            "description" => "Returns a User."
          }
        },
        "/orders" => %{
          "get" => %{
            "description" => "Returns a list of orders."
          }
        }
      }

      assert Swagdox.Renderer.render_spec(spec)["paths"] == expected_paths
    end
  end
end
