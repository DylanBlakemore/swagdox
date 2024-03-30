defmodule Swagdox.Schema do
  @moduledoc """
  This module provides a way to extract the fields and types of an Ecto.Schema.
  """
  defstruct [:module, :type, properties: %{}, required: []]

  @type property :: {atom(), atom()}
  @type t :: %__MODULE__{
          type: String.t(),
          module: module(),
          properties: list(property()),
          required: list(atom())
        }

  @spec __using__(Keyword.t()) :: Macro.t()
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @after_compile Swagdox.Schema

      @spec __swagdox_properties__() :: list(atom()) | nil
      def __swagdox_properties__ do
        Keyword.get(unquote(opts), :only, nil)
      end
    end
  end

  @spec __after_compile__(Macro.Env.t(), Macro.t()) :: Macro.t()
  defmacro __after_compile__(env, _bytecode) do
    check_if_schema(env)
  end

  defp check_if_schema(env) do
    if {:__schema__, 2} not in env.module.__info__(:functions) do
      raise CompileError,
        line: env.line,
        file: env.file,
        description:
          "#{env.module} is not an Ecto.Schema. Make sure to `use Ecto.Schema` and define a schema or embedded_schema block."
    end

    :ok
  end

  @spec infer(module()) :: t()
  def infer(module) do
    %__MODULE__{
      module: module,
      type: "object",
      properties: properties(module)
    }
  end

  @spec properties(module()) :: list(property())
  def properties(schema) do
    properties = schema.__swagdox_properties__() || schema.__schema__(:fields)

    Enum.map(properties, fn property ->
      {property, schema.__schema__(:type, property)}
    end)
  end

  @spec name(t()) :: String.t()
  def name(schema) do
    schema.module
    |> Module.split()
    |> List.last()
  end
end
