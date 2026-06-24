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
  # schema instead of a dangling `$ref` to a non-existent component. A documented
  # `example:` is threaded onto the media type object.
  defp build_content(schema, options) do
    content = %{media_type: "application/json", schema: Type.render(schema)}

    case Keyword.get(options, :example) do
      nil -> [content]
      example -> [Map.put(content, :example, example)]
    end
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

    %{"description" => description}
    |> put_content(content)
    |> put_headers(response.options)
  end

  defp put_content(rendered, nil), do: rendered
  defp put_content(rendered, content), do: Map.put(rendered, "content", render_content(content))

  # An optional `headers:` keyword on `@response` is rendered as the response-level
  # `headers` map. Values are passed through as OpenAPI Header Objects, with map keys
  # stringified so they serialize to valid JSON.
  defp put_headers(rendered, options) when is_list(options) do
    case Keyword.get(options, :headers) do
      nil -> rendered
      headers -> Map.put(rendered, "headers", deep_stringify(headers))
    end
  end

  defp put_headers(rendered, _options), do: rendered

  defp deep_stringify(%{} = map) do
    Map.new(map, fn {key, value} -> {to_string(key), deep_stringify(value)} end)
  end

  defp deep_stringify(list) when is_list(list), do: Enum.map(list, &deep_stringify/1)
  defp deep_stringify(value), do: value

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
