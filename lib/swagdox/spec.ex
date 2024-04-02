defmodule Swagdox.Spec do
  @moduledoc """
  OpenAPI specification.
  """
  alias Swagdox.Config
  alias Swagdox.Parameter
  alias Swagdox.Path
  alias Swagdox.PathBuilder
  alias Swagdox.Response
  alias Swagdox.Schema
  alias Swagdox.SchemaBuilder

  defstruct [
    :config,
    :openapi,
    info: %{},
    servers: [],
    paths: [],
    tags: [],
    schemas: [],
    security: []
  ]

  @type t :: %__MODULE__{
          config: Config.t(),
          openapi: String.t(),
          info: map(),
          servers: list(map()),
          paths: list(map()),
          tags: list(map()),
          schemas: list(),
          security: list()
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
      schemas: [],
      security: []
    }
  end

  @doc """
  Generates the paths for the specification.
  """
  @spec generate_paths(t()) :: t()
  def generate_paths(spec) do
    router = spec.config.router
    paths = PathBuilder.build_paths(router)

    %__MODULE__{spec | paths: paths}
  end

  @doc """
  Generates the schemas for the specification.
  """
  @spec generate_schemas(t()) :: t()
  def generate_schemas(spec) do
    router = spec.config.router
    schemas = SchemaBuilder.build_schemas(router)

    %__MODULE__{spec | schemas: schemas}
  end

  defp info(config) do
    %{
      title: config.title,
      version: config.version,
      description: config.description
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
      "components" => %{
        "schemas" => render_schemas(spec.schemas)
      }
    }
  end

  defp render_schemas(schemas) do
    Enum.reduce(schemas, %{}, fn schema, acc ->
      Map.merge(acc, Schema.render(schema))
    end)
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
      "operationId" => Path.operation_id(path),
      "description" => path.description,
      "parameters" => render_parameters(path.parameters),
      "responses" => render_responses(path.responses)
    }
  end

  defp render_parameters(parameters) do
    Enum.map(parameters, &Parameter.render/1)
  end

  defp render_responses(responses) do
    case Enum.map(responses, &Response.render/1) do
      [] ->
        %{}

      responses ->
        Enum.reduce(responses, &Map.merge/2)
    end
  end
end
