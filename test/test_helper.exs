ExUnit.start()

Application.put_env(:swagdox, :version, "0.1")
Application.put_env(:swagdox, :title, "Swagdox")

Application.put_env(
  :swagdox,
  :description,
  "A library for generating OpenAPI documentation from Elixir code."
)

Application.put_env(:swagdox, :servers, ["http://localhost:4000"])
Application.put_env(:swagdox, :router, Swagdox.Router)
