defmodule Swagdox.Extractor do
  @moduledoc """
  Extracts function docs that contain Open API specifications.
  """

  @type description :: String.t()
  @type specification :: String.t()
  @type extraction :: {atom(), description(), specification()}

  @locale "en"

  @doc """
  Extracts function docs that contain Open API specifications.
  A function doc is considered to contain an Open API specification if it contains
  the string "API:", followed by one or more lines that start with @-variables.

  An example of a function doc that contains an Open API specification:

      Returns a User.

      API:
        @path GET /users/:id
        @param id, integer, required, "User ID"

        @response 200, "User found"
        @response 403, "User not authorized"
        @response 404, "User not found"
  """
  @spec extract(module()) :: {:ok, [extraction()]} | {:error, String.t()}
  def extract(module) do
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
        |> Enum.map(&separate_description/1)

      {:error, {:invalid_chunk, binary}} ->
        {:error, "Invalid chunk: #{binary}"}

      {:error, :module_not_found} ->
        {:error, "Module not found"}

      {:error, :chunk_not_found} ->
        {:error, "Chunk not found"}
    end
  end

  defp extract_function_doc({{_, _, _}, _, _, :none, _}), do: nil
  defp extract_function_doc({{_, _, _}, _, _, :hidden, _}), do: nil

  defp extract_function_doc({{:function, function, _}, _, _, doc_content, _}) do
    {function, Map.get(doc_content, @locale)}
  end

  defp extract_function_doc({{_type, _, _}, _, _, _, _}), do: nil

  defp api_docs?(nil), do: false

  defp api_docs?({_function, doc_content}) do
    doc_content
    |> String.split("\n")
    |> Enum.any?(fn line -> String.trim(line) == "API:" end)
  end

  defp separate_description({function, doc_content}) do
    [description, spec] =
      doc_content
      |> String.split("API:\n")

    {function, String.trim(description), spec}
  end
end
