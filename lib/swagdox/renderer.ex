defmodule Swagdox.Renderer do
  @moduledoc """
  Renders a Spec instance to a valid OpenAPI specification.
  """
  alias Swagdox.Spec

  @doc """
  Renders an OpenAPI specification to a basic map.
  """
  @spec render_spec(Spec.t()) :: map()
  def render_spec(spec) do
    %{
      "openapi" => spec.openapi,
      "info" => render_info(spec.info),
      "servers" => render_servers(spec.servers),
      "paths" => render_paths(spec.paths),
      "tags" => [],
      "components" => %{}
    }
  end

  defp render_info(info) do
    %{
      "title" => info.title,
      "version" => info.version,
      "description" => info.description
    }
  end

  defp render_servers(servers) do
    Enum.map(servers, fn server ->
      %{
        "url" => server
      }
    end)
  end

  defp render_paths(paths) do
    grouped_paths = Enum.group_by(paths, & &1.path)

    Enum.reduce(grouped_paths, %{}, fn {path, paths}, acc ->
      acc_path =
        Enum.reduce(paths, %{}, fn path, acc_path ->
          Map.put(acc_path, path.verb, render_path(path))
        end)

      Map.put(acc, path, acc_path)
    end)
  end

  defp render_path(path) do
    %{
      "description" => path.description
    }
  end
end
