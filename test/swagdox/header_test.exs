defmodule Swagdox.HeaderTest do
  use ExUnit.Case

  alias Swagdox.Header

  describe "build/3" do
    test "builds a header with no constraints" do
      assert %Header{
               name: "X-Rate-Limit",
               type: "integer",
               description: "Requests remaining",
               constraints: []
             } = Header.build("X-Rate-Limit", "integer", "Requests remaining")
    end
  end

  describe "build/4" do
    test "stores constraints" do
      header = Header.build("X-Trace", "string", "Trace id", format: "uuid")

      assert header.constraints == [format: "uuid"]
    end
  end

  describe "render/2" do
    test "renders the header as a name/object pair with a schema" do
      header = Header.build("X-Rate-Limit", "integer", "Requests remaining")

      assert Header.render(header) ==
               {"X-Rate-Limit",
                %{
                  "description" => "Requests remaining",
                  "schema" => %{"type" => "integer"}
                }}
    end

    test "renders the schema according to the OpenAPI version" do
      header = Header.build("X-Trace", "string", "Trace id", nullable: true)

      assert {"X-Trace", %{"schema" => %{"nullable" => true}}} = Header.render(header, "3.0.0")

      assert {"X-Trace", %{"schema" => %{"type" => ["string", "null"]}}} =
               Header.render(header, "3.1.0")
    end
  end
end
