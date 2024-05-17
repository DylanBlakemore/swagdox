defmodule Swagdox.AuthorizationTest do
  use ExUnit.Case

  alias Swagdox.Authorization
  alias SwagdoxWeb.Router

  describe "init/4" do
    test "initializes a security scheme" do
      scheme =
        Authorization.init("apiKey", "ApiAuth", "API key authentication", %{"in" => "header"})

      assert scheme == %Authorization{
               type: "apiKey",
               name: "ApiAuth",
               description: "API key authentication",
               properties: %{"in" => "header"}
             }
    end
  end

  test "extract/1" do
    module = Router
    schemes = Authorization.extract(module)

    assert schemes == [
             %Authorization{
               type: "http",
               name: "BasicAuth",
               description: "Basic http authentication",
               properties: %{"scheme" => "basic"}
             },
             %Authorization{
               type: "apiKey",
               name: "ApiKey",
               description: "API key authentication",
               properties: %{"in" => "header", "name" => "X-API-Key"}
             }
           ]
  end

  describe "extract_scheme/1" do
    test "extracts API auth" do
      scheme = ["ApiKey", {"header", "X-API-Key"}, "API key authentication"]

      assert %Authorization{
               type: "apiKey",
               properties: %{"in" => "header", "name" => "X-API-Key"}
             } = Authorization.extract_scheme(scheme)

      scheme = ["ApiKey", {"query", "api_key"}, "API key authentication"]

      assert %Authorization{
               type: "apiKey",
               properties: %{"in" => "query", "name" => "api_key"}
             } = Authorization.extract_scheme(scheme)
    end

    test "extracts http auth" do
      scheme = ["BasicAuth", "basic", "Basic http authentication"]

      assert %Authorization{
               type: "http",
               properties: %{"scheme" => "basic"}
             } = Authorization.extract_scheme(scheme)

      scheme = ["BearerAuth", "bearer", "Bearer token authentication"]

      assert %Authorization{
               type: "http",
               properties: %{"scheme" => "bearer"}
             } = Authorization.extract_scheme(scheme)
    end
  end

  describe "render/1" do
    test "renders a security scheme" do
      scheme = %Authorization{
        type: "apiKey",
        name: "ApiKey",
        description: "API key authentication",
        properties: %{"in" => "header", "name" => "X-API-Key"}
      }

      assert %{
               "ApiKey" => %{
                 "type" => "apiKey",
                 "description" => "API key authentication",
                 "in" => "header",
                 "name" => "X-API-Key"
               }
             } = Authorization.render(scheme)
    end
  end
end
