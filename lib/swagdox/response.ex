defmodule Swagdox.Response do
  @moduledoc """
  Describes a response in an OpenAPI specification.
  """
  defstruct [:status, :description, :content]

  @type content :: %{media_type: String.t(), schema: map(), example: map()}
  @type t :: %__MODULE__{
          status: integer(),
          description: String.t(),
          content: list(content()) | nil
        }

  @spec build(integer(), String.t(), keyword()) :: t()
  def build(status, description, _options) do
    %__MODULE__{
      status: status,
      description: description,
      content: []
    }
  end

  @spec build(integer(), String.t()) :: t()
  def build(status, description) do
    build(status, description, [])
  end
end
