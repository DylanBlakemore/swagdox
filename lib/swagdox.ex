defmodule Swagdox do
  @moduledoc """
  Swagdox is a library for extracting Open API specifications from Elixir function docs.
  """
  alias Swagdox.Config
  alias Swagdox.Spec

  @spec generate_specification(Config.t()) :: map()
  def generate_specification(config) do
    config
    |> Spec.init()
    |> Spec.generate_paths()
    |> Spec.render()
  end

  @spec generate_specification() :: map()
  def generate_specification do
    generate_specification(Config.init())
  end
end
