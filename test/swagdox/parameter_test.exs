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
               schema: %{
                 type: "object"
               }
             } = Parameter.build({"user", "body"}, "object", "User attributes", required: true)
    end

    test "invalid type" do
      assert_raise ArgumentError, "Invalid type: invalid", fn ->
        Parameter.build({"user", "body"}, "invalid", "User attributes")
      end
    end
  end

  test "build/3" do
    assert %Swagdox.Parameter{
             name: "user",
             in: "body",
             description: "User attributes",
             required: false,
             schema: %{
               type: "object"
             }
           } = Parameter.build({"user", "body"}, "object", "User attributes")
  end

  test "render/1" do
    parameter = %Swagdox.Parameter{
      name: "user",
      in: "body",
      description: "User attributes",
      required: true,
      schema: %{
        type: "string",
        format: "password"
      }
    }

    assert %{
             "name" => "user",
             "in" => "body",
             "description" => "User attributes",
             "required" => true,
             "schema" => %{
               "type" => "string",
               "format" => "password"
             }
           } = Parameter.render(parameter)
  end
end
