defmodule Swagdox.Response do
  @moduledoc """
  Describes a response in an OpenAPI specification.
  """
  alias Swagdox.Type

  defstruct [:status, :description, :content, :options]

  @type t :: %__MODULE__{
          status: integer(),
          description: String.t(),
          content: map() | nil
        }

  @spec build(integer(), String.t() | nil, String.t(), keyword()) :: t()
  def build(status, schema, description, options) do
    %__MODULE__{
      status: status,
      description: description,
      content: build_content(schema, options),
      options: options
    }
  end

  @spec build(integer(), String.t(), keyword()) :: t()
  def build(status, description, options) when is_list(options) do
    build(status, nil, description, options)
  end

  @spec build(integer(), String.t(), String.t()) :: t()
  def build(status, schema, description) do
    build(status, schema, description, [])
  end

  @spec build(integer(), String.t()) :: t()
  def build(status, description) do
    build(status, nil, description, [])
  end

  defp build_content(nil, _options), do: nil

  # Render the schema the same way parameters and request bodies do, so primitive
  # types (`string`, `integer`, ...) and arrays of primitives produce a real inline
  # schema instead of a dangling `$ref` to a non-existent component.
  defp build_content(schema, _options) do
    [
      %{
        media_type: "application/json",
        schema: Type.render(schema)
      }
    ]
  end

  @doc """
  Renders a response to a map.

  ## Examples

      iex> response = Response.build(200, "User", "OK")
      iex> Response.render(response)
      %{
        "200" => %{
          "description" => "OK",
          "content" => %{
            "application/json" => %{
              "schema" => %{
                "$ref" => "#/components/schemas/User"
              }
            }
          }
        }
      }

      iex> response = Response.build(200, "OK")
      iex> Response.render(response)
      %{
        "200" => %{
          "description" => "OK"
        }
      }
  """
  @spec render(t()) :: map()
  def render(response) do
    status = Integer.to_string(response.status)

    %{
      status => render_response(response)
    }
  end

  defp render_response(response) do
    %{description: description, content: content} = response
    rendered = %{"description" => description}

    case content do
      nil -> rendered
      _ -> Map.put(rendered, "content", render_content(content))
    end
  end

  defp render_content(content) do
    Enum.reduce(content, %{}, fn value, acc ->
      rendered =
        %{"schema" => value.schema}
        |> put_example(value[:example])

      Map.put(acc, value.media_type, rendered)
    end)
  end

  defp put_example(content, nil), do: content
  defp put_example(content, example), do: Map.put(content, "example", example)
end
