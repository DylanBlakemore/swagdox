defmodule Swagdox.SchemaBuilder do
  @moduledoc """
  Builds a list of all schemas by inspecting the router to
  get a list of the controllers.
  """
  alias Swagdox.Schema

  @spec build_schemas() :: list(Schema.t())
  def build_schemas do
    app_name = Mix.Project.config()[:app]
    {:ok, modules} = :application.get_key(app_name, :modules)

    modules
    |> Enum.filter(&schema?/1)
    |> Enum.map(fn module -> Schema.infer(module) end)
  end

  defp schema?(module) do
    module
    |> Swagdox.Parser.extract_module_doc()
    |> String.contains?("[Swagdox] Schema:")
  end
end
