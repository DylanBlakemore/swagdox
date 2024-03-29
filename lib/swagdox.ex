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

  @spec write_json(Config.t(), String.t()) :: :ok
  def write_json(config, path) do
    spec = generate_specification(config)
    File.write!(path, Jason.encode!(spec, pretty: true), [:binary])
  end

  @spec write_json(String.t()) :: :ok
  def write_json(path) do
    write_json(Config.init(), path)
  end

  @spec write_yaml(Config.t(), String.t()) :: :ok
  def write_yaml(config, path) do
    spec = generate_specification(config)
    File.write!(path, Ymlr.document!(spec), [:binary])
  end

  @spec write_yaml(String.t()) :: :ok
  def write_yaml(path) do
    write_yaml(Config.init(), path)
  end
end
