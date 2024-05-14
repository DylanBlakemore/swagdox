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
    |> Spec.generate_schemas()
    |> Spec.render()
  end

  @spec write_json(Config.t(), String.t()) :: :ok
  def write_json(config, path) do
    spec = generate_specification(config)
    File.write!(path, Jason.encode!(spec, pretty: true), [:binary])
  end

  @spec write_yaml(Config.t(), String.t()) :: :ok
  def write_yaml(config, path) do
    spec = generate_specification(config)
    File.write!(path, Ymlr.document!(spec), [:binary])
  end
end
