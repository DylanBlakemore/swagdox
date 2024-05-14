defmodule Swagdox.TypeTest do
  use ExUnit.Case

  alias Swagdox.Type

  describe "render/1" do
    test "primitive types" do
      assert Type.render("integer") == %{"type" => "integer"}
      assert Type.render("number") == %{"type" => "number"}
      assert Type.render("string") == %{"type" => "string"}
      assert Type.render("boolean") == %{"type" => "boolean"}
    end

    test "array type" do
      assert Type.render(["integer"]) == %{"type" => "array", "items" => %{"type" => "integer"}}
    end

    test "reference type" do
      assert Type.render("User") == %{"$ref" => "#/components/schemas/User"}
    end

    test "raises an error for unknown types" do
      assert_raise ArgumentError, "Unknown type: 'foo'", fn ->
        Type.render("foo")
      end
    end

    test "with an atom" do
      assert Type.render(MySchema) == %{"$ref" => "#/components/schemas/MySchema"}
    end
  end
end
