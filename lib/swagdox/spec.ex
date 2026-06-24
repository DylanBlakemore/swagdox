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
      "paths" => render_paths(spec.paths, spec.openapi),
      "tags" => [],
      "components" => %{
        "schemas" => render_schemas(spec.schemas, spec.openapi),
        "securitySchemes" => render_security_schemes(spec.security)
      }
    }
  end

  defp render_schemas(schemas, version) do
    Enum.reduce(schemas, %{}, fn schema, acc ->
      Map.merge(acc, Schema.render(schema, version))
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

  defp render_paths(paths, version) do
    operation_ids = assign_operation_ids(paths)
    grouped_paths = Enum.group_by(paths, & &1.path)

    Enum.reduce(grouped_paths, %{}, fn {path, paths}, acc ->
      acc_path =
        Enum.reduce(paths, %{}, fn path, acc_path ->
          operation_id = Map.fetch!(operation_ids, {path.path, path.verb})
          Map.put(acc_path, to_string(path.verb), render_path(path, operation_id, version))
        end)

      Map.put(acc, path, acc_path)
    end)
  end

  # Builds a unique operationId for every path. The OpenAPI spec requires operationIds
  # to be unique, but the base id (controller-function) collides whenever a single action
  # serves more than one route (e.g. resources PUT/PATCH update twins, or a controller
  # mounted under multiple scopes). Ids that are already unique are kept verbatim so we
  # don't rename existing consumers' generated client functions.
  defp assign_operation_ids(paths) do
    paths
    |> Enum.group_by(&Path.operation_id/1)
    |> Enum.flat_map(fn
      {base_id, [single]} -> [{{single.path, single.verb}, base_id}]
      {base_id, group} -> disambiguate(base_id, group)
    end)
    |> Map.new()
  end

  # First disambiguate by verb (resolves PUT/PATCH twins). If that still collides
  # (same verb at different paths), also append a path-derived slug.
  defp disambiguate(base_id, group) do
    with_verb = Enum.map(group, fn path -> {path, "#{base_id}-#{path.verb}"} end)
    counts = Enum.frequencies(Enum.map(with_verb, fn {_path, id} -> id end))

    Enum.map(with_verb, fn {path, id} ->
      final = if counts[id] > 1, do: "#{id}-#{path_slug(path.path)}", else: id
      {{path.path, path.verb}, final}
    end)
  end

  defp path_slug(path) do
    path
    |> String.trim("/")
    |> String.replace(["{", "}"], "")
    |> String.replace("/", "-")
  end

  defp render_path(path, operation_id, version) do
    base = %{
      "operationId" => operation_id,
      "description" => path.description,
      "parameters" => render_parameters(path.parameters, version),
      "responses" => render_responses(path.responses),
      "tags" => path.tags
    }

    base
    |> put_security(path.security)
    |> put_request_body(path.request_body, version)
  end

  # An operation-level `security: []` is meaningful in OpenAPI - it disables any
  # global security requirement for the operation. Only emit the key when the
  # endpoint actually declared a security requirement.
  defp put_security(base, []), do: base
  defp put_security(base, security), do: Map.put(base, "security", render_security(security))

  defp put_request_body(base, nil, _version), do: base
  defp put_request_body(base, [], _version), do: base

  defp put_request_body(base, body_params, version) do
    Map.put(base, "requestBody", render_request_body(body_params, version))
  end

  defp render_parameters(parameters, version) do
    Enum.map(parameters, &Parameter.render(&1, version))
  end

  defp render_request_body([single_param], version) do
    %{
      "required" => single_param.required,
      "content" => %{
        "application/json" => %{
          "schema" => Swagdox.Type.render(single_param.type, single_param.constraints, version)
        }
      }
    }
  end

  defp render_request_body(body_params, version)
       when is_list(body_params) and length(body_params) > 1 do
    # Combine multiple body parameters into a single object schema with properties
    properties =
      Enum.reduce(body_params, %{}, fn param, acc ->
        Map.put(acc, param.name, Swagdox.Type.render(param.type, param.constraints, version))
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

  # The OpenAPI Responses Object is required and must contain at least one entry,
  # so fall back to a `default` response when the endpoint documents none.
  defp render_responses([]), do: %{"default" => %{"description" => "Default response"}}

  defp render_responses(responses) do
    responses
    |> Enum.map(&Response.render/1)
    |> Enum.reduce(&Map.merge/2)
  end

  defp render_security(security) do
    Enum.map(security, &Security.render/1)
  end
end
