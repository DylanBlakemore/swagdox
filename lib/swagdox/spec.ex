defmodule Swagdox.Spec do
  @moduledoc """
  OpenAPI specification.
  """
  alias Swagdox.Config
  alias Swagdox.Parameter
  alias Swagdox.PathDetector

  defstruct [
    :config,
    :openapi,
    info: %{},
    servers: [],
    paths: [],
    tags: [],
    components: %{}
  ]

  @type t :: %__MODULE__{
          config: Config.t(),
          openapi: String.t(),
          info: map(),
          servers: list(map()),
          paths: list(map()),
          tags: list(map()),
          components: map()
        }

  @doc """
  Initializes a new OpenAPI specification.
  """
  @spec init(Config.t()) :: t()
  def init(config) do
    %__MODULE__{
      config: config,
      openapi: config.openapi_version,
      info: info(config),
      servers: config.servers,
      paths: [],
      tags: [],
      components: components()
    }
  end

  @doc """
  Generates the paths for the specification.
  """
  @spec generate_paths(t()) :: t()
  def generate_paths(spec) do
    router = spec.config.router
    paths = PathDetector.build_paths(router)

    %__MODULE__{spec | paths: paths}
  end

  defp info(config) do
    %{
      title: config.title,
      version: config.version,
      description: config.description
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
          Map.put(acc_path, to_string(path.verb), render_path(path))
        end)

      Map.put(acc, path, acc_path)
    end)
  end

  defp render_path(path) do
    %{
      "description" => path.description,
      "parameters" => render_parameters(path.parameters),
      "responses" => %{}
    }
  end

  defp render_parameters(parameters) do
    Enum.map(parameters, &Parameter.render/1)
  end
end
