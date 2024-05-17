defmodule Swagdox.SecurityTest do
  use ExUnit.Case

  alias Swagdox.Security

  test "build/2" do
    assert %Security{
             name: "name",
             scopes: ["scope"]
           } = Security.build("name", ["scope"])
  end

  test "build/1" do
    assert %Security{
             name: "name",
             scopes: []
           } = Security.build("name")
  end

  test "render/1" do
    security = %Security{
      name: "name",
      scopes: ["scope"]
    }

    assert %{"name" => ["scope"]} = Security.render(security)
  end
end
