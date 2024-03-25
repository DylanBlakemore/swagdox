defmodule Swagdox.Spec do
  @moduledoc """
  OpenAPI specification.
  """
  alias Swagdox.Config
  alias Swagdox.Parameter
  alias Swagdox.Path

  defstruct [
    :openapi,
    :info,
    :servers,
    :paths,
    :tags,
    :components
  ]

  @type t :: %__MODULE__{}

  @doc """
  Initializes a new OpenAPI specification.
  """
  @spec init() :: t()
  def init do
    %__MODULE__{
      openapi: Config.openapi_version(),
      info: info(),
      servers: Config.api_servers(),
      paths: [],
      tags: [],
      components: components()
    }
  end

  @doc """
  Assigns the paths in the specification.
  """
  @spec set_paths(t(), list(Path.t())) :: t()
  def set_paths(spec, paths) do
    %{spec | paths: paths}
  end

  defp info do
    %{
      title: Config.api_title(),
      version: Config.api_version(),
      description: Config.api_description()
    }
  end

  defp components do
    %{
      schemas: [],
      securitySchemes: []
    }
  end

  @spec render(t()) :: map()
  def render(spec) do
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
      "description" => path.description,
      "parameters" => render_parameters(path.parameters)
    }
  end

  defp render_parameters(parameters) do
    Enum.map(parameters, &Parameter.render/1)
  end
end
