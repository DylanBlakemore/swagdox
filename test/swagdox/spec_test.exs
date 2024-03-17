defmodule Swagdox.SpecTest do
  use ExUnit.Case

  alias Swagdox.Spec

  test "init/0" do
    assert %Swagdox.Spec{
             openapi: "3.0.0",
             info: %{
               title: "Swagdox",
               version: "0.1",
               description: _description
             },
             servers: [_server],
             paths: %{},
             tags: [],
             components: %{
               schemas: %{},
               securitySchemes: %{}
             }
           } = Spec.init()
  end
end
