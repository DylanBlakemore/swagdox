defmodule Swagdox.Parser do
  @moduledoc """
  Parses endpoint docstrings to extract Open API specification data.
  """

  @spec extract_description(String.t()) :: String.t()
  def extract_description(docstring) do
    docstring
    |> String.split("API:\n")
    |> Enum.at(0)
    |> String.trim()
  end

  @doc """
  Extracts the parameter details from a line in the Open API specification.

  Examples:

        iex> extract_arguments("id, integer, required, \"User ID\"")
        [:id, :integer, :required, "User ID"]

        iex> extract_arguments("id, integer, \"User ID\"")
        [:id, :integer, "User ID"]
  """
  @spec extract_arguments(String.t()) :: {:ok, list()} | {:error, String.t()}
  def extract_arguments(line) do
    with {:ok, ast} <- to_structured("[#{line}]") do
      parse_ast(ast)
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp to_structured(line) do
    case Code.string_to_quoted(line) do
      {:ok, ast} -> {:ok, ast}
      {:error, _} -> {:error, "Unable to parse line: #{line}"}
    end
  end

  defp parse_ast(ast) when is_list(ast) do
    {:ok, Enum.map(ast, &parse_node/1)}
  end

  defp parse_ast(_ast) do
    {:error, "Invalid AST"}
  end

  defp parse_node({value, _meta, nil}) do
    to_string(value)
  end

  defp parse_node({name, _, [{location, _, nil}]}) do
    {to_string(name), to_string(location)}
  end

  defp parse_node(value) when is_binary(value) do
    value
  end
end
