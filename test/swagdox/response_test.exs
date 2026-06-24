defmodule Swagdox.ResponseTest do
  use ExUnit.Case

  alias Swagdox.Header
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
                   "$ref" => "#/components/schemas/User"
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
                   "$ref" => "#/components/schemas/User"
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
                   "type" => "array",
                   "items" => %{"$ref" => "#/components/schemas/User"}
                 }
               }
             ]
    end

    test "builds a response with a primitive type" do
      response = Response.build(200, "string", "OK")

      assert response.content == [
               %{
                 media_type: "application/json",
                 schema: %{"type" => "string"}
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
              "$ref" => "#/components/schemas/User"
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
              "type" => "array",
              "items" => %{"$ref" => "#/components/schemas/User"}
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

    test "renders a primitive schema inline" do
      response = Response.build(200, "string", "OK")

      assert Response.render(response) == %{
               "200" => %{
                 "description" => "OK",
                 "content" => %{
                   "application/json" => %{
                     "schema" => %{"type" => "string"}
                   }
                 }
               }
             }
    end

    test "renders a documented example on the media type" do
      response = %Response{Response.build(200, "User", "OK") | example: %{id: 1, name: "Alice"}}

      assert Response.render(response) == %{
               "200" => %{
                 "description" => "OK",
                 "content" => %{
                   "application/json" => %{
                     "schema" => %{"$ref" => "#/components/schemas/User"},
                     "example" => %{id: 1, name: "Alice"}
                   }
                 }
               }
             }
    end

    test "renders an example even when the response has no schema" do
      response = %Response{Response.build(200, "OK") | example: %{message: "done"}}

      assert Response.render(response) == %{
               "200" => %{
                 "description" => "OK",
                 "content" => %{
                   "application/json" => %{"example" => %{message: "done"}}
                 }
               }
             }
    end

    test "renders documented response headers via the Header struct" do
      response = %Response{
        Response.build(200, "User", "OK")
        | headers: [Header.build("X-Rate-Limit", "integer", "Requests remaining")]
      }

      assert %{
               "200" => %{
                 "headers" => %{
                   "X-Rate-Limit" => %{
                     "description" => "Requests remaining",
                     "schema" => %{"type" => "integer"}
                   }
                 }
               }
             } = Response.render(response)
    end

    test "renders header schemas according to the OpenAPI version" do
      response = %Response{
        Response.build(200, "User", "OK")
        | headers: [Header.build("X-Trace", "string", "Trace id", nullable: true)]
      }

      assert %{"200" => %{"headers" => %{"X-Trace" => %{"schema" => %{"nullable" => true}}}}} =
               Response.render(response, "3.0.0")

      assert %{
               "200" => %{
                 "headers" => %{"X-Trace" => %{"schema" => %{"type" => ["string", "null"]}}}
               }
             } =
               Response.render(response, "3.1.0")
    end
  end
end
