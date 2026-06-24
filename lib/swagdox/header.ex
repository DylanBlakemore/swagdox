defmodule Swagdox.Header do
  @moduledoc """
  Describes a response header in an OpenAPI specification.

  A header is shaped like a parameter without a `name`/`in` (those are implied by
  the response `headers` map key and the location), so it carries a description and
  a schema. The schema is rendered through `Swagdox.Type`, so it honors the same
  type, constraint, and version handling as parameters and request bodies.
  """
  alias Swagdox.Type

  defstruct [:name, :description, :type, constraints: []]

  @type t :: %__MODULE__{
          name: String.t(),
          description: String.t(),
          type: any(),
          constraints: keyword()
        }

  @spec build(String.t(), any(), String.t()) :: t()
  @spec build(String.t(), any(), String.t(), keyword()) :: t()
  def build(name, type, description, constraints \\ []) do
    %__MODULE__{
      name: name,
      description: description,
      type: type,
      constraints: constraints
    }
  end

  @doc """
  Renders a header as a `{name, header_object}` pair, suitable for merging into a
  response's `headers` map.
  """
  @spec render(t()) :: {String.t(), map()}
  @spec render(t(), String.t()) :: {String.t(), map()}
  def render(header, version \\ "3.0.0") do
    {header.name,
     %{
       "description" => header.description,
       "schema" => Type.render(header.type, header.constraints, version)
     }}
  end
end
