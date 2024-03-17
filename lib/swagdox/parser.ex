defmodule Swagdox.Parser do
  @moduledoc """
  Parses endpoint docstrings to extract Open API specification data.
  """

  defmodule ParserError do
    defexception message: "Parser error"
  end

  @configuration_keys [
    "@param",
    "@response"
  ]

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

        iex> extract_config("@param user, map, \"User attributes\"")
        {"@param", "user, map, \"User attributes\""}
  """
  @spec extract_config(String.t()) :: {:ok, {atom(), String.t()}} | {:error, String.t()}
  def extract_config(line) do
    trimmed = String.trim(line)

    case String.split(trimmed, " ", parts: 2) do
      [key, value] when key in @configuration_keys ->
        {:ok, {key, value}}

      _ ->
        {:error, "Invalid configuration: #{trimmed}"}
    end
  end

  @doc """
  Extracts the parameter details from a line in the Open API specification.

  Examples:

        iex> extract_arguments("id(query), integer, \"User ID\", required: true")
        [{"id", "query"}, "integer", "User ID", {:required, true}]
  """
  @spec extract_arguments(String.t()) :: {:ok, list()} | {:error, String.t()}
  def extract_arguments(line) do
    case to_structured("[#{line}]") do
      {:ok, ast} -> parse_ast(ast)
      {:error, reason} -> {:error, reason}
    end
  rescue
    ParserError -> {:error, "Unable to parse argument"}
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

  defp parse_node(_value) do
    raise ParserError
  end
end
