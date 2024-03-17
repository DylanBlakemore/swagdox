defmodule Swagdox.Parameter do
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

  @spec schema(String.t(), keyword()) :: map()
  def schema(type, _opts) when type in @standard_types do
    %{
      type: type
    }
  end
end
