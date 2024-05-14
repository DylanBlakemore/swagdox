defmodule Swagdox.Type do
  @moduledoc """
  Describes a type in an OpenAPI specification.
  """

  @primitive_types [
    "integer",
    "number",
    "string",
    "boolean",
    "object"
  ]

  @type variable :: String.t() | [String.t()] | atom() | [atom()]

  @spec render(variable()) :: map()
  def render(type) when type in @primitive_types do
    %{"type" => type}
  end

  def render([type]) do
    %{"type" => "array", "items" => render(type)}
  end

  def render(type) when is_atom(type) do
    type
    |> to_string()
    |> String.replace("Elixir.", "")
    |> render()
  end

  def render(type) do
    if String.match?(type, ~r/^[A-Z]/) do
      reference(type)
    else
      raise ArgumentError, "Unknown type: '#{type}'"
    end
  end

  @spec reference(String.t() | atom()) :: map()
  def reference(type) do
    %{"$ref" => "#/components/schemas/#{type}"}
  end
end
