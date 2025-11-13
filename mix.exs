defmodule Swagdox.MixProject do
  use Mix.Project

  def project do
    [
      app: :swagdox,
      description: "Generate OpenAPI specs from documentation comments in Elixir modules.",
      version: "0.2.1",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      preferred_cli_env: ["test.all": :test],
      deps: deps(),
      docs: docs(),
      dialyzer: [plt_add_apps: [:mix]],
      package: package(),
      source_url: "https://github.com/DylanBlakemore/swagdox",
      homepage_url: "https://github.com/DylanBlakemore/swagdox",
      test_coverage: [
        summary: [threshold: 95],
        ignore_modules: [
          Mix.Tasks.Swagdox.Generate,
          Swagdox.Order,
          Swagdox.User,
          SwagdoxWeb.DefaultConfig,
          SwagdoxWeb.Router,
          SwagdoxWeb.UserController,
          SwagdoxWeb.OrderController
        ]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:dev), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:ex_doc, "~> 0.31", only: [:dev, :docs], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:jason, "~> 1.4"},
      {:ymlr, "~> 5.0"},
      {:ecto, "~> 3.11", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      "test.lint": [
        "credo --strict",
        "format --check-formatted --dry-run",
        "dialyzer"
      ],
      "test.all": [
        "test --cover --export-coverage default",
        "test.coverage",
        "test.lint"
      ]
    ]
  end

  defp docs do
    [
      main: "readme",
      formatters: ["html", "epub"],
      extras: extras(),
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"]
    ]
  end

  defp extras do
    [
      "README.md",
      "CHANGELOG.md",
      "LICENSE.md"
    ]
  end

  defp package() do
    [
      files: ~w(lib .formatter.exs mix.exs README* LICENSE* CHANGELOG*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/DylanBlakemore/swagdox"}
    ]
  end
end
