defmodule Swagdox.Parameter do
  @moduledoc """
  Describes a parameter in an OpenAPI specification.
  """

  alias Swagdox.Type

  defstruct [
    :name,
    :in,
    :required,
    :description,
    :type,
    constraints: []
  ]

  @type t :: %__MODULE__{
          name: String.t(),
          in: String.t(),
          required: boolean(),
          description: String.t(),
          type: any(),
          constraints: keyword()
        }

  @doc """
  Creates a new Parameter.

  Examples:

        iex> Swagdox.Parameter.build({"id", "query"}, "integer", "User ID")
        %Swagdox.Parameter{
          name: "id",
          in: "query",
          required: false,
          description: "User ID",
          schema: %{type: "integer"}
        }
        iex> Swagdox.Parameter.build({"id", "query"}, "integer", "User ID", required: true)
        %Swagdox.Parameter{
          name: "id",
          in: "query",
          required: true,
          description: "User ID",
          schema: %{type: "integer"}
        }
  """
  @spec build(tuple(), String.t(), String.t()) :: t()
  def build(name_and_location, type, description) do
    build(name_and_location, type, description, [])
  end

  @spec build(tuple() | String.t(), String.t(), String.t(), keyword()) :: t()
  def build({name, location}, type, description, opts) do
    %__MODULE__{
      name: name,
      in: location,
      # OpenAPI requires `required: true` for path parameters; force it regardless
      # of what the docstring declared.
      required: location == "path" or Keyword.get(opts, :required, false),
      description: description,
      type: type,
      constraints: Keyword.delete(opts, :required)
    }
  end

  @doc """
  Renders a Parameter as a map.

  Examples:

        iex> Swagdox.Parameter.render(%Swagdox.Parameter{
        ...>   name: "id",
        ...>   in: "query",
        ...>   required: false,
        ...>   description: "User ID",
        ...>   schema: %{type: "integer"}
        ...> })
        %{
          "name" => "id",
          "in" => "query",
          "required" => false,
          "description" => "User ID",
          "schema" => %{"type" => "integer"}
        }
  """
  @spec render(t()) :: map()
  @spec render(t(), String.t()) :: map()
  def render(parameter, version \\ "3.0.0") do
    %{
      "name" => parameter.name,
      "in" => parameter.in,
      "required" => parameter.required,
      "description" => parameter.description,
      "schema" => Type.render(parameter.type, parameter.constraints, version)
    }
  end
end
