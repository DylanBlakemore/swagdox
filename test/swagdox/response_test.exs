defmodule Swagdox.ResponseTest do
  use ExUnit.Case

  alias Swagdox.Response

  describe "build/3" do
    test "builds a response" do
      response = Response.build(200, "OK", [])

      assert response == %Response{status: 200, description: "OK", content: []}
    end
  end

  describe "build/2" do
    test "builds a response with no options" do
      response = Response.build(200, "OK")

      assert response == %Response{status: 200, description: "OK", content: []}
    end
  end
end
