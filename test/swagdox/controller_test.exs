defmodule Swagdox.ControllerTest do
  use ExUnit.Case

  alias Swagdox.Controller

  defmodule TestController do
    use Controller,
      schemas: [Swagdox.User, Swagdox.Post],
      auth: :header,
      token: "X-HEADER-TOKEN"
  end

  test "controller security" do
    assert TestController.__security__() == %{type: :header, token: "X-HEADER-TOKEN"}
  end
end
