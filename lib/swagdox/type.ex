defmodule Swagdox.Type do
  @moduledoc """
  Describes a type in an OpenAPI specification.

  Types may carry constraints, expressed as a keyword list. Scalar constraints
  (`enum`, `format`, `nullable`, `min_length`, `max_length`, `minimum`, `maximum`,
  `pattern`) attach to the schema itself - or, for array types, to the array items.
  `min_items` and `max_items` attach to the array. Nullability is rendered according
  to the target OpenAPI version: `nullable: true` for 3.0.x, a `"null"` type union
  for 3.1.x.

  A type may also be a composition of other types - `{"one_of", types}`,
  `{"any_of", types}`, or `{"all_of", types}` - which render as the corresponding
  JSON Schema keywords (`oneOf`, `anyOf`, `allOf`). Compositions accept a
  `discriminator` constraint, the OpenAPI hint that tells consumers which member
  of the union applies.
  """

  @primitive_types [
    "integer",
    "number",
    "string",
    "boolean",
    "object"
  ]

  # DSL composition keyword -> OpenAPI schema key.
  @composition_keys %{
    "one_of" => "oneOf",
    "any_of" => "anyOf",
    "all_of" => "allOf"
  }

  @default_version "3.0.0"

  # DSL keyword -> OpenAPI schema key. `nullable` is handled separately (it is
  # version-dependent), and `required` is a parameter-level field, not a schema
  # constraint, so it is stripped before rendering.
  @constraint_keys %{
    enum: "enum",
    format: "format",
    min_length: "minLength",
    max_length: "maxLength",
    minimum: "minimum",
    maximum: "maximum",
    pattern: "pattern",
    min_items: "minItems",
    max_items: "maxItems"
  }

  @array_keys [:min_items, :max_items]

  # Every option that describes the schema, as opposed to its surroundings.
  @schema_keys [:nullable, :discriminator, :required] ++ Map.keys(@constraint_keys)

  @type composition :: {String.t() | atom(), list()}
  @type variable :: String.t() | [String.t()] | atom() | [atom()] | composition()

  @spec render(variable()) :: map()
  @spec render(variable(), keyword()) :: map()
  @spec render(variable(), keyword(), String.t()) :: map()
  def render(type, constraints \\ [], version \\ @default_version)

  def render({composition, []}, _constraints, _version) do
    raise ArgumentError, "#{composition} requires at least one type"
  end

  def render({composition, types}, constraints, version) when is_list(types) do
    %{composition_key(composition) => Enum.map(types, &render(&1, [], version))}
    |> apply_constraints(constraints, version)
  end

  def render(type, constraints, version) when type in @primitive_types do
    apply_constraints(%{"type" => type}, constraints, version)
  end

  def render([type], constraints, version) do
    {array_level, item_level} = Keyword.split(constraints, @array_keys)
    base = %{"type" => "array", "items" => render(type, item_level, version)}
    apply_constraints(base, array_level, version)
  end

  def render(type, constraints, version) when is_atom(type) do
    type
    |> to_string()
    |> String.replace("Elixir.", "")
    |> render(constraints, version)
  end

  def render(type, constraints, version) do
    if String.match?(type, ~r/^[A-Z]/) do
      apply_constraints(reference(type), constraints, version)
    else
      raise ArgumentError, "Unknown type: '#{type}'"
    end
  end

  @doc """
  Splits a keyword list into the options that describe a schema and everything else.

  Used where a DSL tag mixes schema constraints with options that belong elsewhere -
  `@response 200, User, "OK", content_type: "application/json", nullable: true`.
  """
  @spec split_constraints(keyword()) :: {keyword(), keyword()}
  def split_constraints(opts) do
    Keyword.split(opts, @schema_keys)
  end

  @spec reference(String.t() | atom()) :: map()
  def reference(type) do
    %{"$ref" => "#/components/schemas/#{type}"}
  end

  @doc """
  Renders a Discriminator Object.

  Accepts either the discriminator's property name on its own, or a keyword list
  of `:property` and an optional `:mapping` of discriminator value to schema. Bare
  schema names in the mapping are expanded into component references.
  """
  @spec render_discriminator(String.t() | atom() | keyword()) :: map()
  def render_discriminator(property) when is_binary(property) or is_atom(property) do
    %{"propertyName" => to_string(property)}
  end

  def render_discriminator(opts) when is_list(opts) do
    property =
      Keyword.get(opts, :property) ||
        raise ArgumentError, "A discriminator requires a :property"

    case Keyword.get(opts, :mapping) do
      nil -> render_discriminator(property)
      mapping -> Map.put(render_discriminator(property), "mapping", render_mapping(mapping))
    end
  end

  defp render_mapping(mapping) do
    Enum.into(mapping, %{}, fn {value, schema} ->
      {to_string(value), mapped_reference(schema)}
    end)
  end

  # A mapping value may already be an explicit reference (or any other URI); a bare
  # schema name is expanded to a component reference, as the OpenAPI spec allows both.
  defp mapped_reference(schema) do
    name = String.replace(to_string(schema), "Elixir.", "")

    if String.contains?(name, "/") do
      name
    else
      "#/components/schemas/#{name}"
    end
  end

  defp composition_key(composition) do
    case Map.fetch(@composition_keys, to_string(composition)) do
      {:ok, key} -> key
      :error -> raise ArgumentError, "Unknown composition: #{inspect(composition)}"
    end
  end

  defp composition?(base) do
    Enum.any?(Map.values(@composition_keys), &Map.has_key?(base, &1))
  end

  defp apply_constraints(base, constraints, version) do
    {nullable, constraints} = Keyword.pop(constraints, :nullable, false)
    {discriminator, constraints} = Keyword.pop(constraints, :discriminator)
    constraints = Keyword.delete(constraints, :required)

    base
    |> merge_constraints(constraints)
    |> apply_discriminator(discriminator)
    |> apply_nullable(nullable, version)
  end

  defp apply_discriminator(base, nil), do: base

  defp apply_discriminator(base, discriminator) do
    if composition?(base) do
      Map.put(base, "discriminator", render_discriminator(discriminator))
    else
      raise ArgumentError, "A discriminator is only valid on a one_of, any_of, or all_of type"
    end
  end

  defp merge_constraints(base, constraints) do
    rendered =
      Enum.into(constraints, %{}, fn {key, value} ->
        case Map.fetch(@constraint_keys, key) do
          {:ok, json_key} -> {json_key, value}
          :error -> raise ArgumentError, "Unknown constraint: #{inspect(key)}"
        end
      end)

    # OpenAPI 3.0 forbids siblings of `$ref`, so wrap in `allOf` when constraints
    # must be attached to a reference. Primitive and array bases merge directly.
    case base do
      %{"$ref" => _} when rendered != %{} -> Map.merge(%{"allOf" => [base]}, rendered)
      _ -> Map.merge(base, rendered)
    end
  end

  defp apply_nullable(map, false, _version), do: map

  defp apply_nullable(map, true, version) do
    if String.starts_with?(version, "3.0") do
      Map.put(map, "nullable", true)
    else
      nullable_union(map)
    end
  end

  defp nullable_union(%{"type" => type} = map) when is_binary(type) do
    Map.put(map, "type", [type, "null"])
  end

  defp nullable_union(map) do
    # A `$ref`, `allOf`, or already-list type can't fold `"null"` into its type,
    # so express the union explicitly.
    %{"anyOf" => [map, %{"type" => "null"}]}
  end
end
