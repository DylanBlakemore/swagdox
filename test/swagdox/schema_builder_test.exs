defmodule Swagdox.SchemaBuilderTest do
  use ExUnit.Case

  alias Swagdox.Order
  alias Swagdox.Schema
  alias Swagdox.SchemaBuilder
  alias Swagdox.User

  describe "build_schemas/0" do
    test "builds schemas for valid controllers" do
      schemas = SchemaBuilder.build_schemas()

      assert [
               %Schema{module: Order},
               %Schema{module: User}
             ] = schemas
    end
  end
end
