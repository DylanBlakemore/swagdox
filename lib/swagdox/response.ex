defmodule Swagdox.Response do
  @moduledoc """
  Describes a response in an OpenAPI specification.
  """
  alias Swagdox.Schema

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

  defp build_content([schema], _options) do
    [
      %{
        media_type: "application/json",
        schema: %{
          type: "array",
          ref: Schema.reference(schema)
        }
      }
    ]
  end

  defp build_content(schema, _options) do
    [
      %{
        media_type: "application/json",
        schema: %{
          ref: Schema.reference(schema)
        }
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

  defp render_response(%__MODULE__{description: description, content: content}) do
    rendered = %{"description" => description}

    case content do
      nil -> rendered
      _ -> Map.put(rendered, "content", render_content(content))
    end
  end

  defp render_content(content) do
    Enum.reduce(content, %{}, fn value, acc ->
      rendered =
        %{}
        |> put_schema(value.schema)
        |> put_example(value[:example])

      Map.put(acc, value.media_type, rendered)
    end)
  end

  defp put_schema(content, %{type: "array", ref: ref}) do
    Map.put(content, "schema", %{"type" => "array", "items" => %{"$ref" => ref}})
  end

  defp put_schema(content, %{ref: ref}) do
    Map.put(content, "schema", %{"$ref" => ref})
  end

  defp put_schema(_content, _schema) do
    raise RuntimeError, "Only reference schemas supported for responses at this stage"
  end

  defp put_example(content, nil), do: content
end
