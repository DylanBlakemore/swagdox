defmodule Swagdox.PathDetector do
  @moduledoc """
  Builds paths from a router by calling the __routes__ function.

  We can then use the Endpoint.extract_all/1 function to extract the API specification
  from the controller modules.
  """
  alias Swagdox.Endpoint
  alias Swagdox.Path

  @spec build_paths(module()) :: list(Path.t())
  def build_paths(router) do
    case Keyword.has_key?(router.__info__(:functions), :__routes__) do
      true -> build_router_paths(router.__routes__())
      false -> []
    end
  end

  @spec build_router_paths(list(Path.route())) :: list(Path.t())
  def build_router_paths(routes) do
    controller_modules =
      routes
      |> Enum.map(& &1.plug)
      |> Enum.uniq()

    endpoints =
      controller_modules
      |> Enum.flat_map(&extract_endpoints(&1))
      |> collate_endpoints()

    routes
    |> Enum.map(&build_path(&1, endpoints))
    |> Enum.reject(&is_nil/1)
  end

  defp extract_endpoints(controller) do
    case Endpoint.extract_all(controller) do
      {:ok, endpoints} -> endpoints
      {:error, _} -> []
    end
  end

  defp build_path(route, endpoints) do
    key = doc_key(route.plug, route.plug_opts)
    endpoint = Map.get(endpoints, key)

    case endpoint do
      nil -> nil
      _endpoint -> Path.build(endpoint, route)
    end
  end

  defp collate_endpoints(endpoints) do
    endpoints
    |> Enum.reduce(%{}, fn endpoint, acc ->
      Map.put(acc, doc_key(endpoint.module, endpoint.function), endpoint)
    end)
  end

  defp doc_key(controller, function), do: "#{controller}.#{function}"
end
