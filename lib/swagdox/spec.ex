defmodule Swagdox.Spec do
  @moduledoc """
  OpenAPI specification.
  """
  alias Swagdox.Authorization
  alias Swagdox.Config
  alias Swagdox.Parameter
  alias Swagdox.Path
  alias Swagdox.PathBuilder
  alias Swagdox.Response
  alias Swagdox.Schema
  alias Swagdox.SchemaBuilder
  alias Swagdox.Security

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
    schemas = SchemaBuilder.build_schemas()

    %__MODULE__{spec | schemas: schemas}
  end

  @doc """
  Generates security schemes for the specification.
  """
  @spec generate_security_schemes(t()) :: t()
  def generate_security_schemes(spec) do
    security_schemes = Authorization.extract(spec.config.router)

    %__MODULE__{spec | security: security_schemes}
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
        "schemas" => render_schemas(spec.schemas),
        "securitySchemes" => render_security_schemes(spec.security)
      }
    }
  end

  defp render_schemas(schemas) do
    Enum.reduce(schemas, %{}, fn schema, acc ->
      Map.merge(acc, Schema.render(schema))
    end)
  end

  defp render_security_schemes(security_schemes) do
    Enum.reduce(security_schemes, %{}, fn scheme, acc ->
      Map.merge(acc, Authorization.render(scheme))
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
    base = %{
      "operationId" => Path.operation_id(path),
      "description" => path.description,
      "parameters" => render_parameters(path.parameters),
      "responses" => render_responses(path.responses),
      "security" => render_security(path.security),
      "tags" => path.tags
    }

    case path.request_body do
      nil -> base
      [] -> base
      body_params -> Map.put(base, "requestBody", render_request_body(body_params))
    end
  end

  defp render_parameters(parameters) do
    Enum.map(parameters, &Parameter.render/1)
  end

  defp render_request_body([single_param]) do
    %{
      "required" => single_param.required,
      "content" => %{
        "application/json" => %{
          "schema" => Swagdox.Type.render(single_param.type)
        }
      }
    }
  end

  defp render_request_body(body_params) when is_list(body_params) and length(body_params) > 1 do
    # Combine multiple body parameters into a single object schema with properties
    properties =
      Enum.reduce(body_params, %{}, fn param, acc ->
        Map.put(acc, param.name, Swagdox.Type.render(param.type))
      end)

    required_fields =
      body_params
      |> Enum.filter(& &1.required)
      |> Enum.map(& &1.name)

    schema = %{
      "type" => "object",
      "properties" => properties
    }

    schema =
      if required_fields != [] do
        Map.put(schema, "required", required_fields)
      else
        schema
      end

    %{
      "required" => Enum.any?(body_params, & &1.required),
      "content" => %{
        "application/json" => %{
          "schema" => schema
        }
      }
    }
  end

  defp render_responses([]), do: %{}

  defp render_responses(responses) do
    responses
    |> Enum.map(&Response.render/1)
    |> Enum.reduce(&Map.merge/2)
  end

  defp render_security(security) do
    Enum.map(security, &Security.render/1)
  end
end
