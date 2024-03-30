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

    if is_nil(parsed[:output]) do
      raise """
      Missing required argument: --output
      """
    end

    output = parsed[:output]
    format = parsed[:format] || "json"

    config = config(parsed)

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

  defp config(args) do
    title = title(args[:title])
    version = version(args[:version])
    description = description(args[:description])
    servers = servers(args[:servers])
    router = router(args[:router])

    check_missing_config(:title, title)
    check_missing_config(:router, router)

    Swagdox.Config.new(
      title: title,
      version: version,
      description: description,
      servers: servers,
      router: router
    )
  end

  defp check_missing_config(key, value) do
    if is_nil(value) do
      raise """
      Missing required configuration: #{key}
      """
    end
  end

  defp router(nil), do: Application.get_env(:swagdox, :router)

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

  defp servers(nil), do: Application.get_env(:swagdox, :servers, [])
  defp servers(servers), do: String.split(servers, ",")

  defp title(nil), do: Application.get_env(:swagdox, :title)
  defp title(title), do: title

  defp version(nil), do: Application.get_env(:swagdox, :version, "0.1.0")
  defp version(version), do: version

  defp description(nil), do: Application.get_env(:swagdox, :description, "")
  defp description(description), do: description
end
