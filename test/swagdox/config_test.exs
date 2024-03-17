defmodule Swagdox.ConfigTest do
  use ExUnit.Case

  alias Swagdox.Config

  test "openapi_version/0" do
    assert Config.openapi_version() == "3.0.0"
  end

  test "api_version/0" do
    assert Config.api_version() == "0.1"
  end

  test "api_title/0" do
    assert Config.api_title() == "Swagdox"
  end

  test "api_description/0" do
    assert Config.api_description() ==
             "A library for generating OpenAPI documentation from Elixir code."
  end

  test "api_servers/0" do
    assert Config.api_servers() == ["http://localhost:4000"]
  end

  test "api_router/0" do
    assert Config.api_router() == Swagdox.Router
  end
end
