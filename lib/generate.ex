defmodule Mix.Tasks.Swagdox.Generate do
  @shortdoc "Generates OpenAPI specification from Elixir function docs."
  @moduledoc """
  Generates OpenAPI specification from Elixir function docs.

  Command line options can be used to specify the output title, version, description, servers,
  and router module for the OpenAPI specification. However, if these options are not provided, the
  values will attempt to be fetched from the application config.

  ## Usage

      mix swagdox.generate --output path/to/output.json
      mix swagdox.generate -o path/to/output.json

  ## Options

  * `--output` - (required) The path to write the output file.
  * `--format` - The format of the output file. Default is `json`.
  * `--title` - The title of the API.
  * `--version` - The version of the API.
  * `--description` - The description of the API.
  * `--servers` - The servers of the API.
  * `--router` - The router module to use.
  """

  use Mix.Task

  @requirements ["app.config"]

  @impl Mix.Task
  @spec run(list(String.t())) :: :ok
  def run(args) do
    Mix.Task.run("app.start")

    {parsed, _, _} =
      OptionParser.parse(args,
        aliases: [
          o: :output,
          f: :format,
          t: :title,
          v: :version,
          d: :description,
          s: :servers,
          r: :router
        ],
        strict: [
          output: :string,
          format: :string,
          title: :string,
          version: :string,
          description: :string,
          servers: :string,
          router: :string
        ]
      )

    config = config(parsed)

    case config.format do
      "json" ->
        Swagdox.write_json(config, config.output)

      "yaml" ->
        Swagdox.write_yaml(config, config.output)

      _ ->
        raise """
        Invalid format: #{config.format}
        """
    end
  end

  defp config(args) do
    title = title(args[:title])
    version = version(args[:version])
    description = description(args[:description])
    servers = servers(args[:servers])
    router = router(args[:router])
    output = output(args[:output])
    format = format(args[:format])

    Swagdox.Config.new(
      title: title,
      version: version,
      description: description,
      servers: servers,
      router: router,
      output: output,
      format: format
    )
  end

  defp router(nil), do: project_config(:router)

  defp router(router) do
    String.to_existing_atom("Elixir.#{router}")
  rescue
    _error in ArgumentError ->
      reraise(
        """
        Invalid router: #{router}
        """,
        __STACKTRACE__
      )
  end

  defp servers(nil), do: project_config(:servers, [])
  defp servers(servers), do: String.split(servers, ",")

  defp title(nil), do: project_config(:title)
  defp title(title), do: title

  defp version(nil), do: project_config(:version, "0.1.0")
  defp version(version), do: version

  defp description(nil), do: project_config(:description, "")
  defp description(description), do: description

  defp output(nil), do: project_config(:output)
  defp output(output), do: output

  defp format(nil), do: project_config(:format, "json")
  defp format(format), do: format

  defp project_config(opt, default) do
    Mix.Project.config()[:swagdox][opt] || default
  end

  defp project_config(opt) do
    Mix.Project.config()[:swagdox][opt] || raise("Missing required configuration: #{opt}")
  end
end
