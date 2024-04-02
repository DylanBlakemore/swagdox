defmodule Swagdox.SchemaBuilderTest do
  use ExUnit.Case

  alias Swagdox.Schema
  alias Swagdox.SchemaBuilder

  defmodule TestController1 do
    use Swagdox.Controller,
      schemas: [Swagdox.User]
  end

  defmodule TestController2 do
  end

  defmodule TestRouter do
    @spec __routes__() :: list()
    def __routes__ do
      [
        %{plug: TestController1},
        %{plug: TestController2}
      ]
    end
  end

  defmodule FakeRouter do
  end

  describe "build_schemas/1" do
    test "builds schemas for valid controllers" do
      schemas = SchemaBuilder.build_schemas(TestRouter)

      assert [
               %Schema{module: Swagdox.User}
             ] = schemas
    end

    test "returns empty list for invalid routers" do
      assert [] = SchemaBuilder.build_schemas(FakeRouter)
    end
  end
end
