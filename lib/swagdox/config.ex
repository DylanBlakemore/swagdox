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
    :router,
    :output,
    :format
  ]

  @type t :: %__MODULE__{}
  @open_api_version "3.0.0"

  @spec new(map() | keyword()) :: t()
  def new(opts) do
    opts = Enum.into(opts, %{openapi_version: @open_api_version})

    struct(__MODULE__, opts)
  end
end
