defmodule Swagdox.ConfigTest do
  use ExUnit.Case

  alias Swagdox.Config

  test "new/1" do
    assert %Config{openapi_version: "3.0.0"} =
             Config.new(
               version: "0.1",
               title: "Swagdox",
               description: "A library for generating OpenAPI documentation from Elixir code.",
               servers: ["http://localhost:4000"],
               router: SwagdoxWeb.Router
             )
  end
end
