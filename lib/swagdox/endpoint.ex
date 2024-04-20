defmodule Swagdox.Endpoint do
  @moduledoc """
  Describes  a documented endpoint in an application controller.
  """

  alias Swagdox.Parameter
  alias Swagdox.Parser
  alias Swagdox.Response

  defstruct [:module, :function, :docstring]

  @type docstring :: String.t()
  @type t :: %__MODULE__{
          module: module(),
          function: atom(),
          docstring: docstring()
        }

  @locale "en"

  @doc """
  Returns the parameters for the endpoint.
  """
  @spec parameters(t()) :: list(Parameter.t())
  def parameters(endpoint) do
    endpoint.docstring
    |> Parser.extract_params()
    |> Enum.map(&Parser.parse_definition/1)
    |> Enum.reject(&body_param?/1)
    |> Enum.map(&build_param/1)
  end

  defp body_param?({:param, [{_, "body"} | _rest]}), do: true
  defp body_param?(_), do: false

  defp build_param({:param, [value, type, description]}) do
    Parameter.build(value, type, description)
  end

  defp build_param({:param, [value, type, description, opts]}) do
    Parameter.build(value, type, description, opts)
  end

  defp build_param({:error, reason}), do: raise(ArgumentError, reason)

  @doc """
  Returns the responses for the endpoint.
  """
  @spec responses(t()) :: list(Response.t())
  def responses(endpoint) do
    endpoint.docstring
    |> Parser.extract_responses()
    |> Enum.map(&Parser.parse_definition/1)
    |> Enum.map(&build_response/1)
  end

  defp build_response({:response, [status, schema, description]}) do
    Response.build(status, schema, description)
  end

  defp build_response({:response, [status, schema, description, opts]}) do
    Response.build(status, schema, description, opts)
  end

  defp build_response({:response, [status, description]}) do
    Response.build(status, description)
  end

  @doc """
  Extracts function docs that contain Open API specifications.
  A function doc is considered to contain an Open API specification if it contains
  the string "[Swagdox] API:", followed by one or more lines that start with @-variables.

  An example of a function doc that contains an Open API specification:

      Returns a User.

      [Swagdox] API:
        @param id, integer, required, "User ID"

        @response 200, User, "User found"
        @response 403, "User not authorized"
        @response 404, "User not found"
  """
  @spec extract_all(module()) :: {:ok, list(t())} | {:error, String.t()}
  def extract_all(module) do
    case extract_function_docs(module) do
      {:error, reason} -> {:error, reason}
      function_docs -> {:ok, function_docs}
    end
  end

  defp extract_function_docs(module) do
    case Code.fetch_docs(module) do
      {:docs_v1, _, _, _, _, _, function_docs} ->
        function_docs
        |> Enum.map(&extract_function_doc/1)
        |> Enum.filter(&api_docs?/1)
        |> Enum.map(fn {function, docstring} ->
          %__MODULE__{module: module, function: function, docstring: docstring}
        end)

      {:error, :module_not_found} ->
        {:error, "Module '#{inspect(module)}' not found"}
    end
  end

  defp extract_function_doc({{:function, function, _}, _, _, doc_content, _})
       when is_map(doc_content) do
    {function, Map.get(doc_content, @locale)}
  end

  defp extract_function_doc(_), do: nil

  defp api_docs?(nil), do: false

  defp api_docs?({_function, doc_content}) do
    doc_content
    |> String.split("\n")
    |> Enum.any?(fn line -> String.trim(line) == "[Swagdox] API:" end)
  end
end
