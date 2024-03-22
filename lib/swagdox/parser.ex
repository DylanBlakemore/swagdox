defmodule Swagdox.Parser do
  @moduledoc """
  Parses endpoint docstrings to extract Open API specification data.
  """

  defmodule ParserError do
    defexception message: "Parser error"
  end

  @doc """
  Extracts the description from a docstring.

  Examples:

        iex> extract_description("Creates a User.")
        "Creates a User."
  """
  @spec extract_description(String.t()) :: String.t()
  def extract_description(docstring) do
    docstring
    |> String.split("API:\n")
    |> Enum.at(0)
    |> String.trim()
  end

  @doc """
  Extracts the type of configuration and its value from a line in the Open API specification.

  Examples:

        iex> parse_definition("@param user(query), map, \"User attributes\"")
        {:param, [{"user", "query"}, "map", "User attributes"]}
  """
  @spec parse_definition(String.t()) :: {:ok, {atom(), list()}} | {:error, String.t()}
  def parse_definition(line) do
    case to_ast(line) do
      {:ok, {:@, _, [{func, _, params}]}} ->
        {:ok, {func, parse_ast(params)}}

      {:ok, _} ->
        {:error, "Invalid syntax"}

      {:error, reason} ->
        {:error, reason}
    end
  rescue
    e in ParserError -> {:error, e.message}
  end

  defp to_ast(line) do
    case Code.string_to_quoted(line) do
      {:ok, ast} -> {:ok, ast}
      {:error, _} -> {:error, "Unable to parse line: #{line}"}
    end
  end

  defp parse_ast(ast) when is_list(ast) do
    Enum.map(ast, &parse_node/1)
  end

  defp parse_node({value, _meta, nil}) do
    to_string(value)
  end

  defp parse_node({name, _, [{location, _, nil}]}) do
    {to_string(name), to_string(location)}
  end

  defp parse_node({name, value}) when is_atom(name) do
    {name, parse_node(value)}
  end

  defp parse_node(value) when is_binary(value) or is_boolean(value) or is_number(value) do
    value
  end

  defp parse_node(node) when is_list(node) do
    Enum.map(node, &parse_node/1)
  end

  defp parse_node(node) do
    raise ParserError, message: "Unable to parse node: #{inspect(node)}"
  end
end
