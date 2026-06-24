defmodule Swagdox.ParameterTest do
  use ExUnit.Case

  alias Swagdox.Parameter

  describe "build/4" do
    test "standard type" do
      assert %Swagdox.Parameter{
               name: "user",
               in: "body",
               description: "User attributes",
               required: true,
               type: "object"
             } = Parameter.build({"user", "body"}, "object", "User attributes", required: true)

      assert %Swagdox.Parameter{
               name: "id",
               in: "query",
               description: "User ID",
               required: false,
               type: "integer"
             } = Parameter.build({"id", "query"}, "integer", "User ID", required: false)
    end

    test "path parameters are always required" do
      assert %Swagdox.Parameter{
               name: "id",
               in: "path",
               required: true
             } = Parameter.build({"id", "path"}, "integer", "User ID", required: false)

      assert %Swagdox.Parameter{in: "path", required: true} =
               Parameter.build({"id", "path"}, "integer", "User ID")
    end

    test "arrays" do
      assert %Swagdox.Parameter{
               name: "id",
               in: "body",
               description: "User IDs",
               required: true,
               type: ["integer"]
             } = Parameter.build({"id", "body"}, ["integer"], "User IDs", required: true)
    end

    test "stores constraint opts, separate from :required" do
      param =
        Parameter.build({"id", "body"}, ["integer"], "User IDs", required: true, min_items: 1)

      assert param.required == true
      assert param.constraints == [min_items: 1]
    end
  end

  test "build/3" do
    assert %Swagdox.Parameter{
             name: "user",
             in: "body",
             description: "User attributes",
             required: false,
             type: "object"
           } = Parameter.build({"user", "body"}, "object", "User attributes")
  end

  test "render/1" do
    parameter = %Swagdox.Parameter{
      name: "user",
      in: "body",
      description: "User attributes",
      required: true,
      type: "string"
    }

    assert %{
             "name" => "user",
             "in" => "body",
             "description" => "User attributes",
             "required" => true,
             "schema" => %{
               "type" => "string"
             }
           } = Parameter.render(parameter)

    parameter = %Swagdox.Parameter{
      name: "names",
      in: "body",
      description: "User names",
      required: true,
      type: ["string"]
    }

    assert %{
             "name" => "names",
             "in" => "body",
             "description" => "User names",
             "required" => true,
             "schema" => %{
               "type" => "array",
               "items" => %{
                 "type" => "string"
               }
             }
           } = Parameter.render(parameter)
  end

  test "render/2 emits constraints in the schema" do
    parameter = %Swagdox.Parameter{
      name: "status",
      in: "query",
      description: "Status",
      required: false,
      type: "string",
      constraints: [enum: ["a", "b"]]
    }

    assert %{"schema" => %{"type" => "string", "enum" => ["a", "b"]}} =
             Parameter.render(parameter, "3.0.0")
  end
end
