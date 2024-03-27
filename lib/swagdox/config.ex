defmodule Swagdox.Config do
  @moduledoc """
  Configuration for the Swagdox library.
  """
  defstruct [
    :openapi_version,
    :version,
    :title,
    :description,
    :servers,
    :router
  ]

  @type t :: %__MODULE__{}

  @spec new(map() | keyword()) :: t()
  def new(opts) do
    struct(__MODULE__, opts)
  end

  @spec init() :: t()
  def init do
    new(
      openapi_version: openapi_version(),
      version: api_version(),
      title: api_title(),
      description: api_description(),
      servers: api_servers(),
      router: api_router()
    )
  end

  @spec openapi_version :: String.t()
  def openapi_version, do: "3.0.0"

  @spec api_version :: String.t()
  def api_version do
    Application.get_env(:swagdox, :version, "0.1")
  end

  @spec api_title :: String.t()
  def api_title do
    Application.fetch_env!(:swagdox, :title)
  end

  @spec api_description :: String.t()
  def api_description do
    Application.get_env(:swagdox, :description, "")
  end

  @spec api_servers :: list(String.t())
  def api_servers do
    Application.get_env(:swagdox, :servers, [])
  end

  @spec api_router :: module()
  def api_router do
    Application.fetch_env!(:swagdox, :router)
  end
end
