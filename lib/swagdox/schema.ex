defmodule Swagdox.Schema do
  @moduledoc """
  This module provides a way to extract the fields and types of an Ecto.Schema.
  """
  alias Swagdox.Parser
  alias Swagdox.Type

  defstruct [:module, :description, :example, :type, properties: %{}, required: []]

  @type property :: {atom(), atom(), keyword()}
  @type t :: %__MODULE__{
          type: String.t(),
          module: module(),
          properties: list(property()),
          required: list(atom()),
          description: String.t()
        }

  @spec infer(module()) :: t()
  def infer(module) do
    %__MODULE__{
      module: module,
      type: "object",
      properties: properties(module),
      description: description(module),
      example: example(module)
    }
  end

  @spec example(module()) :: any()
  def example(schema) do
    examples =
      schema
      |> Parser.extract_module_doc()
      |> Parser.extract_example()
      |> Enum.map(&Parser.parse_definition/1)

    case examples do
      [] -> nil
      [{:example, [example]}] -> example
      [_first, _second | _rest] -> raise "Schemas only support a single example"
    end
  end

  @spec description(module()) :: String.t()
  def description(schema) do
    schema
    |> Parser.extract_module_doc()
    |> Parser.extract_description()
  end

  @spec properties(module()) :: list(property())
  def properties(schema) do
    schema
    |> extract_properties()
    |> Enum.map(fn
      {:property, [name, type, _description]} -> {name, type, []}
      {:property, [name, type, _description, constraints]} -> {name, type, constraints}
    end)
  end

  defp extract_properties(schema) do
    schema
    |> Parser.extract_module_doc()
    |> Parser.extract_properties()
    |> Enum.map(&Parser.parse_definition/1)
  end

  @spec name(t()) :: String.t()
  def name(schema) do
    {:name, name} =
      schema.module
      |> Parser.extract_module_doc()
      |> Parser.extract_name()
      |> Parser.parse_definition()

    name
  end

  @spec reference(t() | String.t()) :: String.t()
  def reference(%__MODULE__{} = schema) do
    schema
    |> name()
    |> reference()
  end

  def reference(name) do
    "#/components/schemas/#{name}"
  end

  @spec render(t()) :: map()
  @spec render(t(), String.t()) :: map()
  def render(schema, version \\ "3.0.0") do
    name = name(schema)

    rendered =
      %{
        "description" => schema.description,
        "type" => schema.type,
        "properties" => render_properties(schema.properties, version)
      }
      |> render_example(schema)

    %{name => rendered}
  end

  defp render_example(rendered, %{example: nil}), do: rendered

  defp render_example(rendered, %{example: example}) do
    Map.put(rendered, "example", example)
  end

  defp render_properties(properties, version) do
    Enum.into(properties, %{}, fn {key, type, constraints} ->
      {to_string(key), Type.render(type, constraints, version)}
    end)
  end
end
