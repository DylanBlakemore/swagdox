defmodule SwagdoxWeb.DefaultConfig do
  alias Swagdox.Config

  def config do
    %Config{
      openapi_version: "3.0.0",
      version: "0.1",
      title: "Swagdox",
      description: "A library for generating OpenAPI documentation from Elixir code.",
      servers: ["http://localhost:4000"],
      router: SwagdoxWeb.Router
    }
  end
end
