defmodule Swagdox.Spec do
  @moduledoc """
  OpenAPI specification.
  """
  alias Swagdox.Config
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
end
