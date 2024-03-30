defmodule Swagdox.ResponseTest do
  use ExUnit.Case

  alias Swagdox.Response

  describe "build/4" do
    test "builds a response" do
      response = Response.build(200, "User", "OK", foo: "bar")

      assert %Response{
               status: 200,
               description: "OK",
               options: [foo: "bar"]
             } = response

      assert response.content == [
               %{
                 media_type: "application/json",
                 schema: %{
                   ref: "#/components/schemas/User"
                 }
               }
             ]
    end
  end

  describe "build/3" do
    test "builds a response with no options" do
      response = Response.build(200, "User", "OK")

      assert %Response{
               status: 200,
               description: "OK",
               options: []
             } = response

      assert response.content == [
               %{
                 media_type: "application/json",
                 schema: %{
                   ref: "#/components/schemas/User"
                 }
               }
             ]
    end

    test "builds a respnse with an array type" do
      response = Response.build(200, ["User"], "OK")

      assert %Response{
               status: 200,
               description: "OK",
               options: []
             } = response

      assert response.content == [
               %{
                 media_type: "application/json",
                 schema: %{
                   type: "array",
                   ref: "#/components/schemas/User"
                 }
               }
             ]
    end

    test "builds a response with no schema" do
      response = Response.build(200, "OK", foo: "bar")

      assert %Response{
               status: 200,
               description: "OK",
               content: nil,
               options: [foo: "bar"]
             } = response
    end
  end

  describe "build/2" do
    test "builds a response with no options and no schema" do
      response = Response.build(200, "OK")

      assert response == %Response{status: 200, description: "OK", content: nil, options: []}
    end
  end

  describe "render/1" do
    test "no content" do
      response = %Response{status: 200, description: "OK", content: nil}

      assert Response.render(response) == %{
               "200" => %{
                 "description" => "OK"
               }
             }
    end

    test "content with a schema" do
      response = %Response{
        status: 200,
        description: "OK",
        content: [
          %{
            media_type: "application/json",
            schema: %{
              ref: "#/components/schemas/User"
            },
            example: nil
          }
        ]
      }

      assert Response.render(response) == %{
               "200" => %{
                 "description" => "OK",
                 "content" => %{
                   "application/json" => %{
                     "schema" => %{
                       "$ref" => "#/components/schemas/User"
                     }
                   }
                 }
               }
             }
    end

    test "content with an array schema" do
      response = %Response{
        status: 200,
        description: "OK",
        content: [
          %{
            media_type: "application/json",
            schema: %{
              type: "array",
              ref: "#/components/schemas/User"
            },
            example: nil
          }
        ]
      }

      assert Response.render(response) == %{
               "200" => %{
                 "description" => "OK",
                 "content" => %{
                   "application/json" => %{
                     "schema" => %{
                       "type" => "array",
                       "items" => %{
                         "$ref" => "#/components/schemas/User"
                       }
                     }
                   }
                 }
               }
             }
    end

    test "raises an error if the schema is not a reference" do
      response = %Response{
        status: 200,
        description: "OK",
        content: [
          %{
            media_type: "application/json",
            schema: %{
              type: "object",
              properties: %{
                foo: %{
                  type: "string"
                }
              }
            }
          }
        ]
      }

      assert_raise RuntimeError, fn ->
        Response.render(response)
      end
    end
  end
end
