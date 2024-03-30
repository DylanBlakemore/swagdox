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
      path: adjust_path(route.path),
      verb: route.verb,
      function: endpoint.function,
      controller: endpoint.module,
      parameters: parameters(endpoint),
      responses: responses(endpoint)
    }
  end

  @spec operation_id(t()) :: String.t()
  def operation_id(path) do
    "#{path.controller}-#{path.function}" |> String.replace("Elixir.", "")
  end

  defp parameters(endpoint) do
    Endpoint.parameters(endpoint)
  end

  defp responses(endpoint) do
    Endpoint.responses(endpoint)
  end

  defp adjust_path(path) do
    path
    |> String.split("/")
    |> Enum.map_join("/", &adjust_segment/1)
  end

  defp adjust_segment(segment) do
    case String.split(segment, ":") do
      [_, name] -> "{#{name}}"
      _ -> segment
    end
  end
end
