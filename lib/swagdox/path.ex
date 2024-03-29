defmodule Swagdox.Path do
  @moduledoc """
  Represents a path in the Open API specification.
  """
  alias Swagdox.Endpoint
  alias Swagdox.Parser

  defstruct [
    :description,
    :path,
    :verb,
    :function,
    :controller,
    parameters: [],
    responses: []
  ]

  @type t :: %__MODULE__{}
  @type route :: %{
          path: String.t(),
          plug: module(),
          plug_opts: atom(),
          verb: atom()
        }

  @doc """
  Builds a new Path.

  Examples:

    iex> Swagdox.Path.build(endpoint, route)
    %Swagdox.Path{
      description: "Creates a User.",
      path: "/users",
      verb: :post
    }
  """
  @spec build(Endpoint.t(), route()) :: %__MODULE__{}
  def build(endpoint, route) do
    %__MODULE__{
      description: Parser.extract_description(endpoint.docstring),
      path: route.path,
      verb: route.verb,
      function: endpoint.function,
      controller: endpoint.module
    }
  end

  @spec operation_id(t()) :: String.t()
  def operation_id(path) do
    "#{path.controller}-#{path.function}" |> String.replace("Elixir.", "")
  end
end
