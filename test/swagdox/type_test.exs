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

  describe "render/3 with constraints" do
    test "enum on a primitive" do
      assert Type.render("string", enum: ["a", "b"]) ==
               %{"type" => "string", "enum" => ["a", "b"]}
    end

    test "format" do
      assert Type.render("string", format: "date-time") ==
               %{"type" => "string", "format" => "date-time"}
    end

    test "string length constraints" do
      assert Type.render("string", min_length: 1, max_length: 10) ==
               %{"type" => "string", "minLength" => 1, "maxLength" => 10}
    end

    test "numeric range constraints" do
      assert Type.render("integer", minimum: 0, maximum: 100) ==
               %{"type" => "integer", "minimum" => 0, "maximum" => 100}
    end

    test "pattern" do
      assert Type.render("string", pattern: "^[a-z]+$") ==
               %{"type" => "string", "pattern" => "^[a-z]+$"}
    end

    test "ignores :required (a parameter-level field, not a schema constraint)" do
      assert Type.render("string", required: true) == %{"type" => "string"}
    end

    test "raises on an unknown constraint" do
      assert_raise ArgumentError, "Unknown constraint: :wat", fn ->
        Type.render("string", wat: true)
      end
    end

    test "min_items/max_items attach to the array, scalar constraints to its items" do
      assert Type.render(["string"], min_items: 1, max_items: 5, enum: ["a", "b"]) ==
               %{
                 "type" => "array",
                 "minItems" => 1,
                 "maxItems" => 5,
                 "items" => %{"type" => "string", "enum" => ["a", "b"]}
               }
    end

    test "constraints on an array of references attach to the items" do
      assert Type.render(["User"], min_items: 1) ==
               %{
                 "type" => "array",
                 "minItems" => 1,
                 "items" => %{"$ref" => "#/components/schemas/User"}
               }
    end
  end

  describe "render/3 nullable" do
    test "3.0.x emits nullable: true" do
      assert Type.render("string", [nullable: true], "3.0.0") ==
               %{"type" => "string", "nullable" => true}
    end

    test "3.1.x folds null into the type" do
      assert Type.render("string", [nullable: true], "3.1.0") ==
               %{"type" => ["string", "null"]}
    end

    test "3.1.x preserves sibling constraints when folding null" do
      assert Type.render("string", [nullable: true, enum: ["a"]], "3.1.0") ==
               %{"type" => ["string", "null"], "enum" => ["a"]}
    end

    test "nullable applies to array items, not the array" do
      assert Type.render(["string"], [nullable: true], "3.0.0") ==
               %{
                 "type" => "array",
                 "items" => %{"type" => "string", "nullable" => true}
               }
    end

    test "3.1.x expresses a nullable reference as an anyOf union" do
      assert Type.render("User", [nullable: true], "3.1.0") ==
               %{"anyOf" => [%{"$ref" => "#/components/schemas/User"}, %{"type" => "null"}]}
    end
  end

  describe "render/3 with references" do
    test "wraps a reference in allOf when constraints are present (3.0-valid)" do
      assert Type.render("User", format: "uuid") ==
               %{"allOf" => [%{"$ref" => "#/components/schemas/User"}], "format" => "uuid"}
    end
  end
end
