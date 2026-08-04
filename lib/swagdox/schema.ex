defmodule Swagdox.Schema do
  @moduledoc """
  This module provides a way to extract the fields and types of an Ecto.Schema.

  A schema is an object described by its properties, unless it declares a `@type`
  expression of its own. A `@type` union - `@type Cat | Dog`, or the explicit
  `@type any_of(...)` / `@type all_of(...)` - optionally paired with a
  `@discriminator`, is how polymorphic payloads are described: the schema renders as
  a `oneOf` (or `anyOf`/`allOf`) rather than as a property bag.
  """
  alias Swagdox.Parser
  alias Swagdox.Type

  defstruct [
    :module,
    :description,
    :example,
    :type,
    :discriminator,
    properties: %{},
    required: []
  ]

  @type property :: {atom(), atom(), keyword()}
  @type t :: %__MODULE__{
          type: String.t() | Type.composition(),
          module: module(),
          properties: list(property()),
          required: list(String.t()),
          description: String.t(),
          discriminator: String.t() | keyword() | nil
        }

  @spec infer(module()) :: t()
  def infer(module) do
    props = properties(module)

    %__MODULE__{
      module: module,
      type: type(module),
      properties: props,
      required: required_properties(props),
      description: description(module),
      example: example(module),
      discriminator: discriminator(module)
    }
  end

  # A property documented with `required: true` is collected into the object's
  # `required` list (per the OpenAPI Schema Object), rather than being emitted as
  # a per-property constraint - `Type.render` strips `:required` from the property
  # schema itself.
  defp required_properties(properties) do
    properties
    |> Enum.filter(fn {_name, _type, constraints} ->
      Keyword.get(constraints, :required, false)
    end)
    |> Enum.map(fn {name, _type, _constraints} -> to_string(name) end)
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

  @doc """
  Returns the type the schema declares through `@type`, defaulting to `"object"`.
  """
  @spec type(module()) :: String.t() | Type.composition()
  def type(schema) do
    definitions =
      schema
      |> Parser.extract_module_doc()
      |> Parser.extract_type()
      |> Enum.map(&Parser.parse_definition/1)

    case definitions do
      [] -> "object"
      [{:error, reason}] -> raise ArgumentError, reason
      [{:type, [type]}] -> type
      [_first, _second | _rest] -> raise "Schemas only support a single type"
    end
  end

  @doc """
  Returns the schema's discriminator, if it documents one.
  """
  @spec discriminator(module()) :: String.t() | keyword() | nil
  def discriminator(schema) do
    definitions =
      schema
      |> Parser.extract_module_doc()
      |> Parser.extract_discriminator()
      |> Enum.map(&Parser.parse_definition/1)

    case definitions do
      [] -> nil
      [{:discriminator, [property]}] -> property
      [{:discriminator, [property, mapping]}] -> [property: property, mapping: mapping]
      [_first, _second | _rest] -> raise "Schemas only support a single discriminator"
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
      %{"description" => schema.description}
      |> render_type(schema, version)
      |> render_required(schema)
      |> render_example(schema)
      |> render_discriminator(schema)

    %{name => rendered}
  end

  # A composed schema is not an object, so it emits neither `type` nor `properties` -
  # unless it also documents properties, a valid `allOf` + own-properties combination.
  defp render_type(rendered, %{type: {_composition, _types} = type} = schema, version) do
    rendered = Map.merge(rendered, Type.render(type, [], version))

    case schema.properties do
      empty when empty == [] or empty == %{} ->
        rendered

      properties ->
        Map.merge(rendered, %{
          "type" => "object",
          "properties" => render_properties(properties, version)
        })
    end
  end

  defp render_type(rendered, schema, version) do
    Map.merge(rendered, %{
      "type" => schema.type,
      "properties" => render_properties(schema.properties, version)
    })
  end

  defp render_discriminator(rendered, %{discriminator: nil}), do: rendered

  defp render_discriminator(rendered, %{discriminator: discriminator}) do
    Map.put(rendered, "discriminator", Type.render_discriminator(discriminator))
  end

  defp render_required(rendered, %{required: []}), do: rendered

  defp render_required(rendered, %{required: required}) do
    Map.put(rendered, "required", required)
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
