defmodule Mix.Tasks.Swagdox.Generate do
  @shortdoc "Generates OpenAPI specification from Elixir function docs."
  @moduledoc """
  Generates OpenAPI specification from Elixir function docs.
  """

  use Mix.Task

  @requirements ["app.config"]

  @impl Mix.Task
  @spec run(list(String.t())) :: :ok
  def run(args) do
    {parsed, _, _} =
      OptionParser.parse(args, strict: [output: :string, format: :string])

    if is_nil(parsed[:output]) do
      raise """
      Missing required argument: --output
      """
    end

    output = parsed[:output]
    format = parsed[:format] || "json"

    case format do
      "json" ->
        Swagdox.write_json(output)

      "yaml" ->
        Swagdox.write_yaml(output)

      _ ->
        raise """
        Invalid format: #{format}
        """
    end
  end
end
