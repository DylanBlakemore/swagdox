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
  * `--openapi-version` - The OpenAPI version to target (e.g. `3.0.0` or `3.1.0`). Default is `3.0.0`.
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
          router: :string,
          openapi_version: :string
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
    openapi_version = openapi_version(args[:openapi_version])

    Swagdox.Config.new(
      title: title,
      version: version,
      description: description,
      servers: servers,
      router: router,
      output: output,
      format: format,
      openapi_version: openapi_version
    )
  end

  defp openapi_version(nil) do
    validate_openapi_version(project_config(:openapi_version, "3.0.0"))
  end

  defp openapi_version(version), do: validate_openapi_version(version)

  defp validate_openapi_version(version) do
    if String.starts_with?(version, "3.0") or String.starts_with?(version, "3.1") do
      version
    else
      raise """
      Invalid OpenAPI version: #{version}
      Swagdox supports the 3.0.x and 3.1.x specifications.
      """
    end
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
