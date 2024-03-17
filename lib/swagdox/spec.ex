defmodule Swagdox.Spec do
  @moduledoc """
  OpenAPI specification.
  """
  alias Swagdox.Config

  defstruct [
    :openapi,
    :info,
    :servers,
    :paths,
    :tags,
    :components
  ]

  @type t :: %__MODULE__{}

  @spec init() :: t()
  def init do
    %__MODULE__{
      openapi: Config.openapi_version(),
      info: info(),
      servers: Config.api_servers(),
      paths: %{},
      tags: [],
      components: components()
    }
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
      schemas: %{},
      securitySchemes: %{}
    }
  end
end
