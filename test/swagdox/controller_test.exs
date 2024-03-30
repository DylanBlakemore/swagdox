defmodule Swagdox.ControllerTest do
  use ExUnit.Case

  alias Swagdox.Controller

  defmodule TestController do
    use Controller,
      schemas: [Swagdox.User],
      auth: :header,
      token: "X-HEADER-TOKEN"
  end

  test "controller schemas" do
    assert TestController.__schemas__() == [Swagdox.User]
  end

  test "controller security" do
    assert TestController.__security__() == %{type: :header, token: "X-HEADER-TOKEN"}
  end
end
