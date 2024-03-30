defmodule Swagdox.SchemaTest do
  use ExUnit.Case

  defmodule NoFieldsSchema do
    use Ecto.Schema
    use Swagdox.Schema

    embedded_schema do
      field :foo, :string
      field :bar, :integer
    end
  end

  defmodule WithFieldsSchema do
    use Ecto.Schema
    use Swagdox.Schema, only: [:foo]

    embedded_schema do
      field :foo, :string
      field :bar, :integer
    end
  end

  test "no fields" do
    assert NoFieldsSchema.__swagdox_properties__() == nil
  end

  test "with fields" do
    assert WithFieldsSchema.__swagdox_properties__() == [:foo]
  end

  test "compilation fails if the module is not an ecto schema" do
    quoted =
      quote do
        defmodule NotAnEctoSchema do
          use Swagdox.Schema
        end
      end

    assert_raise CompileError, fn ->
      Code.eval_quoted(quoted)
    end
  end

  test "properties/1" do
    assert Swagdox.Schema.properties(NoFieldsSchema) == [
             {:id, :binary_id},
             {:foo, :string},
             {:bar, :integer}
           ]

    assert Swagdox.Schema.properties(WithFieldsSchema) == [
             {:foo, :string}
           ]
  end

  test "infer/1" do
    assert Swagdox.Schema.infer(NoFieldsSchema) == %Swagdox.Schema{
             type: "object",
             module: NoFieldsSchema,
             properties: [
               {:id, :binary_id},
               {:foo, :string},
               {:bar, :integer}
             ]
           }

    assert Swagdox.Schema.infer(WithFieldsSchema) == %Swagdox.Schema{
             type: "object",
             module: WithFieldsSchema,
             properties: [
               {:foo, :string}
             ]
           }
  end

  test "name/1" do
    assert Swagdox.Schema.name(%Swagdox.Schema{module: NoFieldsSchema}) == "NoFieldsSchema"
  end
end
