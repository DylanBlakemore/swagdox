defmodule Swagdox.Parameter do
  @moduledoc """
  Describes a parameter in an OpenAPI specification.
  """
  defstruct [
    :name,
    :in,
    :required,
    :description,
    :schema
  ]

  @type t :: %__MODULE__{
          name: String.t(),
          in: String.t(),
          required: boolean(),
          description: String.t(),
          schema: map()
        }

  @standard_types [
    "integer",
    "number",
    "string",
    "boolean",
    "array",
    "object"
  ]

  @doc """
  Creates a new Parameter.

  Examples:

        iex> Swagdox.Parameter.new({"id", "query"}, "integer", "User ID")
        %Swagdox.Parameter{
          name: "id",
          in: "query",
          required: false,
          description: "User ID",
          schema: %{type: "integer"}
        }
        iex> Swagdox.Parameter.new({"id", "query"}, "integer", "User ID", required: true)
        %Swagdox.Parameter{
          name: "id",
          in: "query",
          required: true,
          description: "User ID",
          schema: %{type: "integer"}
        }
  """
  @spec new(tuple(), String.t(), String.t()) :: t()
  def new(name_and_location, type, description) do
    new(name_and_location, type, description, [])
  end

  @spec new(tuple(), String.t(), String.t(), keyword()) :: t()
  def new({name, location}, type, description, opts) do
    %__MODULE__{
      name: name,
      in: location,
      required: Keyword.get(opts, :required, false),
      description: description,
      schema: schema(type, opts)
    }
  end

  @doc """
  Returns the schema for a Parameter. Raises an ArgumentError if the type is invalid.

  Examples:

        iex> Swagdox.Parameter.schema("integer", [])
        %{type: "integer"}
        iex> Swagdox.Parameter.schema("integer", format: "int64")
        %{type: "integer", format: "int64"}
  """
  @spec schema(String.t(), keyword()) :: map()
  def schema(type, opts) when type in @standard_types do
    opts
    |> Keyword.drop([:required])
    |> Enum.into(%{
      type: type
    })
  end

  def schema(type, _opts) do
    raise ArgumentError, "Invalid type: #{type}"
  end
end
