defmodule Swagdox.Response do
  @moduledoc """
  Describes a response in an OpenAPI specification.
  """
  alias Swagdox.Header
  alias Swagdox.Type

  defstruct [:status, :description, :content, :options, example: nil, headers: []]

  @type t :: %__MODULE__{
          status: integer(),
          description: String.t(),
          content: list(map()) | nil,
          example: any(),
          headers: list(Header.t())
        }

  @spec build(integer(), String.t() | nil, String.t(), keyword()) :: t()
  def build(status, schema, description, options) do
    %__MODULE__{
      status: status,
      description: description,
      content: build_content(schema),
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

  defp build_content(nil), do: nil

  # Render the schema the same way parameters and request bodies do, so primitive
  # types (`string`, `integer`, ...) and arrays of primitives produce a real inline
  # schema instead of a dangling `$ref` to a non-existent component.
  defp build_content(schema) do
    [%{media_type: "application/json", schema: Type.render(schema)}]
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
  @spec render(t(), String.t()) :: map()
  def render(response, version \\ "3.0.0") do
    status = Integer.to_string(response.status)

    %{status => render_response(response, version)}
  end

  defp render_response(response, version) do
    %{"description" => response.description}
    |> put_content(response.content, response.example)
    |> put_headers(response.headers, version)
  end

  # A documented `@example` is attached to the media type. When a response carries an
  # example but no schema, an `application/json` media type is still emitted so the
  # example has somewhere valid to live.
  defp put_content(rendered, nil, nil), do: rendered

  defp put_content(rendered, nil, example) do
    Map.put(rendered, "content", %{"application/json" => %{"example" => example}})
  end

  defp put_content(rendered, content, example) do
    Map.put(rendered, "content", render_content(content, example))
  end

  defp render_content(content, example) do
    Enum.reduce(content, %{}, fn value, acc ->
      rendered = put_example(%{"schema" => value.schema}, example)
      Map.put(acc, value.media_type, rendered)
    end)
  end

  defp put_example(media_type, nil), do: media_type
  defp put_example(media_type, example), do: Map.put(media_type, "example", example)

  defp put_headers(rendered, [], _version), do: rendered

  defp put_headers(rendered, headers, version) do
    Map.put(rendered, "headers", Map.new(headers, &Header.render(&1, version)))
  end
end
