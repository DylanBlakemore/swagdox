defmodule Swagdox.Security do
  @moduledoc """
  Defines an authorization option for an endpoint in an OpenAPI
  specification.
  """
  defstruct [:name, :scopes]

  @type t :: %__MODULE__{
          name: String.t(),
          scopes: list(String.t())
        }

  @spec build(String.t(), list(String.t())) :: t()
  def build(name, scopes) do
    %__MODULE__{
      name: name,
      scopes: scopes
    }
  end

  @spec build(String.t()) :: t()
  def build(name) do
    build(name, [])
  end

  @spec render(t()) :: map()
  def render(security) do
    %{
      security.name => security.scopes
    }
  end
end
