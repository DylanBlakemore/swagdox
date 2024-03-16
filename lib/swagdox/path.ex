defmodule Swagdox.Path do
  @moduledoc """
  Represents a path in the Open API specification.
  """
  alias Swagdox.Endpoint
  alias Swagdox.Parser

  defstruct [
    :description,
    :path,
    :verb
  ]

  @type t :: %__MODULE__{}
  @type route :: %{
          path: String.t(),
          plug: module(),
          plug_opts: atom(),
          verb: atom()
        }

  @spec build(Endpoint.t(), route()) :: %__MODULE__{}
  def build(endpoint, route) do
    %__MODULE__{
      description: Parser.extract_description(endpoint.docstring),
      path: route.path,
      verb: route.verb
    }
  end
end
