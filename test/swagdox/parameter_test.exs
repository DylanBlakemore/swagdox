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
               in: "path",
               description: "User ID",
               required: false,
               type: "integer"
             } = Parameter.build({"id", "path"}, "integer", "User ID", required: false)
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
end
