defmodule Swagdox.SchemaBuilder do
  @moduledoc """
  Builds a list of all schemas by inspecting the router to
  get a list of the controllers.
  """
  alias Swagdox.Schema

  @spec build_schemas(module()) :: list(Schema.t())
  def build_schemas(router) do
    case Keyword.has_key?(router.__info__(:functions), :__routes__) do
      true -> build_controller_schemas(router.__routes__())
      false -> []
    end
  end

  defp build_controller_schemas(routes) do
    routes
    |> controllers()
    |> Enum.flat_map(fn controller -> controller.__schemas__() end)
    |> Enum.uniq()
    |> Enum.map(fn schema -> Schema.infer(schema) end)
  end

  defp controllers(routes) do
    routes
    |> Enum.map(& &1.plug)
    |> Enum.uniq()
    |> Enum.filter(&controller?/1)
  end

  defp controller?(module) do
    Keyword.has_key?(module.__info__(:functions), :__schemas__)
  end
end
