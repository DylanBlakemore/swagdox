defmodule Swagdox.Type do
  @moduledoc """
  Describes a type in an OpenAPI specification.

  Types may carry constraints, expressed as a keyword list. Scalar constraints
  (`enum`, `format`, `nullable`, `min_length`, `max_length`, `minimum`, `maximum`,
  `pattern`) attach to the schema itself - or, for array types, to the array items.
  `min_items` and `max_items` attach to the array. Nullability is rendered according
  to the target OpenAPI version: `nullable: true` for 3.0.x, a `"null"` type union
  for 3.1.x.
  """

  @primitive_types [
    "integer",
    "number",
    "string",
    "boolean",
    "object"
  ]

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

  @type variable :: String.t() | [String.t()] | atom() | [atom()]

  @spec render(variable()) :: map()
  @spec render(variable(), keyword()) :: map()
  @spec render(variable(), keyword(), String.t()) :: map()
  def render(type, constraints \\ [], version \\ @default_version)

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

  @spec reference(String.t() | atom()) :: map()
  def reference(type) do
    %{"$ref" => "#/components/schemas/#{type}"}
  end

  defp apply_constraints(base, constraints, version) do
    {nullable, constraints} = Keyword.pop(constraints, :nullable, false)
    constraints = Keyword.delete(constraints, :required)

    base
    |> merge_constraints(constraints)
    |> apply_nullable(nullable, version)
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
