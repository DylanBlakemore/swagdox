defmodule SwagdoxTest do
  use ExUnit.Case

  alias Swagdox.Config

  @specification %{
    "components" => %{},
    "info" => %{
      "description" => "A library for generating OpenAPI documentation from Elixir code.",
      "title" => "Swagdox",
      "version" => "0.1"
    },
    "openapi" => "3.0.0",
    "paths" => %{
      "/orders" => %{
        "get" => %{"description" => "Returns a list of Orders", "parameters" => []},
        "post" => %{"description" => "Creates an Order.", "parameters" => []}
      },
      "/orders/:id" => %{
        "get" => %{"description" => "Returns an Order.", "parameters" => []},
        "delete" => %{"description" => "Deletes an Order.", "parameters" => []}
      },
      "/users" => %{"post" => %{"description" => "Creates a User.", "parameters" => []}},
      "/users/:id" => %{"get" => %{"description" => "Returns a User.", "parameters" => []}}
    },
    "servers" => [%{"url" => "http://localhost:4000"}],
    "tags" => []
  }

  describe "generate_specification/1" do
    test "renders a valid OpenAPI specification" do
      config = Config.init()
      spec = Swagdox.generate_specification(config)

      assert spec == @specification
    end
  end

  describe "generate_specification/0" do
    test "renders a valid OpenAPI specification using the default config" do
      spec = Swagdox.generate_specification()

      assert spec == @specification
    end
  end
end
