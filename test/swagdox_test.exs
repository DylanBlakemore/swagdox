defmodule SwagdoxTest do
  use ExUnit.Case

  alias Swagdox.Config

  @specification %{
    "components" => %{
      "schemas" => %{
        "User" => %{
          "properties" => %{
            "email" => %{"type" => "string"},
            "id" => %{"type" => "integer"},
            "name" => %{"type" => "string"}
          },
          "type" => "object"
        },
        "OrderName" => %{
          "properties" => %{"item" => %{"type" => "string"}, "number" => %{"type" => "integer"}},
          "type" => "object"
        }
      }
    },
    "info" => %{
      "description" => "A library for generating OpenAPI documentation from Elixir code.",
      "title" => "Swagdox",
      "version" => "0.1"
    },
    "openapi" => "3.0.0",
    "paths" => %{
      "/orders" => %{
        "get" => %{
          "description" => "Returns a list of Orders",
          "operationId" => "SwagdoxWeb.OrderController-index",
          "parameters" => [],
          "responses" => %{
            "200" => %{
              "content" => %{
                "application/json" => %{
                  "schema" => %{
                    "items" => %{"$ref" => "#/components/schemas/Order"},
                    "type" => "array"
                  }
                }
              },
              "description" => "Orders found"
            },
            "403" => %{"description" => "Orders not authorized"}
          }
        },
        "post" => %{
          "description" => "Creates an Order.",
          "operationId" => "SwagdoxWeb.OrderController-create",
          "parameters" => [],
          "responses" => %{
            "201" => %{
              "content" => %{
                "application/json" => %{"schema" => %{"$ref" => "#/components/schemas/Order"}}
              },
              "description" => "Order created"
            },
            "400" => %{"description" => "Invalid order attributes"}
          }
        }
      },
      "/orders/{id}" => %{
        "delete" => %{
          "description" => "Deletes an Order.",
          "operationId" => "SwagdoxWeb.OrderController-delete",
          "parameters" => [
            %{
              "description" => "Order ID",
              "in" => "path",
              "name" => "id",
              "required" => true,
              "schema" => %{"type" => "integer"}
            }
          ],
          "responses" => %{
            "204" => %{"description" => "Order deleted"},
            "403" => %{"description" => "Order not authorized"},
            "404" => %{"description" => "Order not found"}
          }
        },
        "get" => %{
          "description" => "Returns an Order.",
          "operationId" => "SwagdoxWeb.OrderController-show",
          "parameters" => [
            %{
              "description" => "Order ID",
              "in" => "path",
              "name" => "id",
              "required" => true,
              "schema" => %{"type" => "integer"}
            }
          ],
          "responses" => %{
            "200" => %{
              "content" => %{
                "application/json" => %{"schema" => %{"$ref" => "#/components/schemas/Order"}}
              },
              "description" => "Order found"
            },
            "403" => %{"description" => "Order not authorized"},
            "404" => %{"description" => "Order not found"}
          }
        }
      },
      "/users" => %{
        "post" => %{
          "description" => "Creates a User.",
          "operationId" => "SwagdoxWeb.UserController-create",
          "parameters" => [],
          "responses" => %{
            "201" => %{
              "content" => %{
                "application/json" => %{"schema" => %{"$ref" => "#/components/schemas/User"}}
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
          "operationId" => "SwagdoxWeb.UserController-show",
          "parameters" => [
            %{
              "description" => "User ID",
              "in" => "path",
              "name" => "id",
              "required" => true,
              "schema" => %{"type" => "integer"}
            }
          ],
          "responses" => %{
            "200" => %{
              "content" => %{
                "application/json" => %{"schema" => %{"$ref" => "#/components/schemas/User"}}
              },
              "description" => "User found"
            },
            "403" => %{"description" => "User not authorized"},
            "404" => %{"description" => "User not found"}
          }
        }
      }
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

  describe "write_json/2" do
    test "writes a valid OpenAPI specification to a file" do
      path = "./openapi.json"
      Swagdox.write_json(Config.init(), path)

      assert File.read!(path) == Jason.encode!(@specification, pretty: true)

      File.rm!(path)
    end
  end

  describe "write_json/1" do
    test "writes a valid OpenAPI specification to a file using the default config" do
      path = "./openapi.json"
      Swagdox.write_json(path)

      assert File.read!(path) == Jason.encode!(@specification, pretty: true)

      File.rm!(path)
    end
  end

  describe "write_yaml/2" do
    test "writes a valid OpenAPI specification to a file" do
      path = "./openapi.yaml"
      Swagdox.write_yaml(Config.init(), path)

      assert File.read!(path) == Ymlr.document!(@specification)

      File.rm!(path)
    end
  end

  describe "write_yaml/1" do
    test "writes a valid OpenAPI specification to a file using the default config" do
      path = "./openapi.yaml"
      Swagdox.write_yaml(path)

      assert File.read!(path) == Ymlr.document!(@specification)

      File.rm!(path)
    end
  end
end
