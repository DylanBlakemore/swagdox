defmodule Swagdox.Authorization do
  @moduledoc """
  Defines a security scheme for an OpenAPI document.
  """
  alias Swagdox.Parser
  defstruct [:type, :name, :description, :properties]

  @type t :: %__MODULE__{
          type: String.t(),
          name: String.t(),
          description: String.t(),
          properties: map()
        }

  @basic_types ["bearer", "basic"]
  @api_types ["body", "header", "query", "cookie"]

  @spec init(String.t(), String.t(), String.t(), map()) :: t()
  def init(type, name, description, properties) do
    %__MODULE__{
      type: type,
      name: name,
      description: description,
      properties: properties
    }
  end

  @spec extract(module()) :: list(t())
  def extract(module) do
    docstring = Parser.extract_module_doc(module)
    schemes = Parser.extract_authorizations(docstring)

    schemes
    |> Enum.map(&Parser.parse_definition/1)
    |> Enum.map(fn {:authorization, scheme} -> extract_scheme(scheme) end)
  end

  @spec extract_scheme(list()) :: t()
  def extract_scheme([name, {location, key}, description]) when location in @api_types do
    init("apiKey", name, description, %{"in" => location, "name" => key})
  end

  def extract_scheme([name, type, description]) when type in @basic_types do
    init("http", name, description, %{"scheme" => type})
  end

  @spec render(t()) :: map()
  def render(scheme) do
    default_props = %{
      "type" => scheme.type,
      "description" => scheme.description
    }

    %{
      scheme.name => Map.merge(default_props, scheme.properties)
    }
  end
end
