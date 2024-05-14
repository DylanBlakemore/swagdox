defmodule Swagdox.Parser do
  @moduledoc """
  Parses endpoint docstrings to extract Open API specification data.
  """

  @locations ["query", "header", "path", "cookie", "body"]
  @local "en"

  defmodule ParserError do
    defexception message: "Parser error"
  end

  @doc """
  Extracts the module docstring from a module.
  """
  @spec extract_module_doc(module()) :: String.t()
  def extract_module_doc(module) do
    case Code.fetch_docs(module) do
      {_, _, _, _, %{@local => moduledoc}, _, _} -> moduledoc
      _ -> ""
    end
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
    |> String.split("[Swagdox] API:\n")
    |> Enum.at(0)
    |> String.trim()
  end

  @spec extract_name(String.t()) :: String.t()
  def extract_name(docstring) do
    case extract_elements(docstring, "@name") do
      [name] -> name
      [] -> raise ArgumentError, message: "No name detected in docstring: #{docstring}"
      _names -> raise ArgumentError, message: "Multiple names detected in docstring: #{docstring}"
    end
  end

  @spec extract_properties(String.t()) :: list(String.t())
  def extract_properties(docstring) do
    extract_elements(docstring, "@property")
  end

  @spec extract_params(String.t()) :: list(String.t())
  def extract_params(docstring) do
    extract_elements(docstring, "@param")
  end

  @spec extract_responses(String.t()) :: list(String.t())
  def extract_responses(docstring) do
    extract_elements(docstring, "@response")
  end

  defp extract_elements(docstring, prefix) do
    docstring
    |> String.split(~r/\[Swagdox\] \w+:\n/)
    |> Enum.at(1)
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.filter(&String.starts_with?(&1, prefix))
  end

  @doc """
  Extracts the type of configuration and its value from a line in the Open API specification.

  Examples:

        iex> parse_definition("@param user(query), map, \"User attributes\"")
        {:param, [{"user", "query"}, "map", "User attributes"]}
  """
  @spec parse_definition(String.t()) :: {atom(), list()} | {:error, String.t()}
  def parse_definition(line) do
    case to_ast(line) do
      {:ok, {:@, _, [{func, _, params}]}} ->
        check_shape({func, parse_ast(params)})

      {:ok, _} ->
        {:error, "Invalid syntax"}

      {:error, reason} ->
        {:error, reason}
    end
  rescue
    e in ParserError -> {:error, e.message}
  end

  defp check_shape({:param, [name | _rest]}) when not is_tuple(name) do
    {:error,
     "Parameter :#{name} missing location. The correct syntax is 'name(location)', where location is one of: #{@locations |> Enum.join(", ")}"}
  end

  defp check_shape({:param, [{name, location} | _rest]}) when location not in @locations do
    {:error,
     "Invalid location: #{location} for parameter :#{name}. Must be one of: #{@locations}"}
  end

  defp check_shape({:response, [status | _rest]}) when not is_integer(status) do
    {:error, "Response status must be an integer"}
  end

  defp check_shape({:name, [name]}) do
    {:name, name}
  end

  defp check_shape(definition), do: definition

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

  defp parse_node({:__aliases__, _meta, [value]}) do
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
