defmodule Swagdox.SchemaTest do
  use ExUnit.Case

  alias Swagdox.Order
  alias Swagdox.Schema
  alias Swagdox.User

  test "properties/1" do
    assert Schema.properties(Order) == [
             {"item", "string", [min_length: 1]},
             {"number", "integer", [minimum: 1]},
             {"status", "string", [enum: ["pending", "shipped", "delivered"]]}
           ]
  end

  test "description/1" do
    assert Schema.description(Order) == "An order placed by a customer"
  end

  test "example/1" do
    assert Schema.example(Order) == %{item: "item", number: 1}
  end

  test "infer/1" do
    assert Schema.infer(Order) == %Schema{
             type: "object",
             module: Order,
             properties: [
               {"item", "string", [min_length: 1]},
               {"number", "integer", [minimum: 1]},
               {"status", "string", [enum: ["pending", "shipped", "delivered"]]}
             ],
             description: "An order placed by a customer",
             example: %{item: "item", number: 1}
           }
  end

  test "name/1" do
    assert Schema.name(%Schema{module: Order}) == "OrderName"
  end

  describe "reference/1" do
    test "with a schema" do
      assert Schema.reference(%Schema{module: Order}) ==
               "#/components/schemas/OrderName"
    end

    test "with a string" do
      assert Schema.reference("OrderName") == "#/components/schemas/OrderName"
    end
  end

  test "render/1" do
    schema = %Schema{
      type: "object",
      module: Order,
      properties: [{"item", "string", []}, {"number", "integer", []}]
    }

    assert Schema.render(schema) == %{
             "OrderName" => %{
               "description" => nil,
               "type" => "object",
               "properties" => %{
                 "item" => %{"type" => "string"},
                 "number" => %{"type" => "integer"}
               }
             }
           }
  end

  test "render/2 with property constraints" do
    schema = %Schema{
      type: "object",
      module: Order,
      properties: [
        {"status", "string", [enum: ["new", "done"]]},
        {"created_at", "string", [format: "date-time"]}
      ]
    }

    assert %{
             "OrderName" => %{
               "properties" => %{
                 "status" => %{"type" => "string", "enum" => ["new", "done"]},
                 "created_at" => %{"type" => "string", "format" => "date-time"}
               }
             }
           } = Schema.render(schema)
  end

  test "render/2 renders nullable per the OpenAPI version" do
    schema = %Schema{
      type: "object",
      module: Order,
      properties: [{"title", "string", [nullable: true]}]
    }

    assert %{"OrderName" => %{"properties" => %{"title" => %{"nullable" => true}}}} =
             Schema.render(schema, "3.0.0")

    assert %{"OrderName" => %{"properties" => %{"title" => %{"type" => ["string", "null"]}}}} =
             Schema.render(schema, "3.1.0")
  end

  test "render/1 with arrays" do
    schema = Schema.infer(User)

    assert Schema.render(schema) == %{
             "User" => %{
               "description" => "A user of the application",
               "properties" => %{
                 "email" => %{"type" => "string", "format" => "email"},
                 "id" => %{"type" => "integer"},
                 "name" => %{"type" => "string", "nullable" => true},
                 "orders" => %{
                   "type" => "array",
                   "maxItems" => 100,
                   "items" => %{"$ref" => "#/components/schemas/OrderName"}
                 }
               },
               "type" => "object",
               "required" => ["email"]
             }
           }
  end

  test "render/1 emits the object-level required array" do
    schema = %Schema{
      type: "object",
      module: Order,
      properties: [{"item", "string", []}, {"number", "integer", []}],
      required: ["item"]
    }

    assert %{"OrderName" => %{"required" => ["item"]}} = Schema.render(schema)
  end

  test "infer/1 collects required properties from the required: true constraint" do
    schema = Schema.infer(User)

    assert schema.required == ["email"]
    # The constraint is lifted to the object level, not left on the property schema.
    refute Schema.render(schema)["User"]["properties"]["email"][:required]
  end
end
