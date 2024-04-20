defmodule Swagdox.SchemaTest do
  use ExUnit.Case

  alias Swagdox.Order

  test "properties/1" do
    assert Swagdox.Schema.properties(Order) == [{"item", "string"}, {"number", "integer"}]
  end

  test "infer/1" do
    assert Swagdox.Schema.infer(Order) == %Swagdox.Schema{
             type: "object",
             module: Order,
             properties: [{"item", "string"}, {"number", "integer"}]
           }
  end

  test "name/1" do
    assert Swagdox.Schema.name(%Swagdox.Schema{module: Order}) == "OrderName"
  end

  describe "reference/1" do
    test "with a schema" do
      assert Swagdox.Schema.reference(%Swagdox.Schema{module: Order}) ==
               "#/components/schemas/OrderName"
    end

    test "with a string" do
      assert Swagdox.Schema.reference("OrderName") == "#/components/schemas/OrderName"
    end
  end

  test "render/1" do
    schema = %Swagdox.Schema{
      type: "object",
      module: Order,
      properties: [{"item", "string"}, {"number", "integer"}]
    }

    assert Swagdox.Schema.render(schema) == %{
             "OrderName" => %{
               "type" => "object",
               "properties" => %{
                 "item" => %{"type" => "string"},
                 "number" => %{"type" => "integer"}
               }
             }
           }
  end
end
