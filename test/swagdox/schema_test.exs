defmodule Swagdox.SchemaTest do
  use ExUnit.Case

  alias Swagdox.Order
  alias Swagdox.Schema
  alias Swagdox.User

  test "properties/1" do
    assert Schema.properties(Order) == [{"item", "string"}, {"number", "integer"}]
  end

  test "description/1" do
    assert Schema.description(Order) == "An order placed by a customer"
  end

  test "infer/1" do
    assert Schema.infer(Order) == %Schema{
             type: "object",
             module: Order,
             properties: [{"item", "string"}, {"number", "integer"}],
             description: "An order placed by a customer"
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
      properties: [{"item", "string"}, {"number", "integer"}]
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

  test "render/1 with arrays" do
    schema = Schema.infer(User)

    assert Schema.render(schema) == %{
             "User" => %{
               "description" => "A user of the application",
               "properties" => %{
                 "email" => %{"type" => "string"},
                 "id" => %{"type" => "integer"},
                 "name" => %{"type" => "string"},
                 "orders" => %{
                   "type" => "array",
                   "items" => %{"$ref" => "#/components/schemas/OrderName"}
                 }
               },
               "type" => "object"
             }
           }
  end
end
