defmodule Mix.Tasks.Swagdox.Generate do
  @shortdoc "Generates OpenAPI specification from Elixir function docs."
  @moduledoc """
  Generates OpenAPI specification from Elixir function docs.
  """

  use Mix.Task

  alias Swagdox.Config
  alias SwagdoxWeb.DefaultConfig

  @impl Mix.Task
  @spec run(list(String.t())) :: :ok
  def run(args) do
    {parsed, _, _} =
      OptionParser.parse(args, strict: [output: :string, format: :string, test: :boolean])

    if is_nil(parsed[:output]) do
      raise """
      Missing required argument: --output
      """
    end

    output = parsed[:output]
    format = parsed[:format] || "json"
    test = parsed[:test] || false

    config = config(test)

    case format do
      "json" ->
        Swagdox.write_json(config, output)

      "yaml" ->
        Swagdox.write_yaml(config, output)

      _ ->
        raise """
        Invalid format: #{format}
        """
    end
  end

  defp config(true), do: DefaultConfig.config()
  defp config(false), do: Config.init()
end
