![CI Pipeline](https://github.com/dylanblakemore/swagdox/actions/workflows/elixir.yml/badge.svg)

# Swagdox

Swagdox is a Swagger/OpenAPI specification generator inspired by [Swaggeryard](https://github.com/livingsocial/swagger_yard).

While multiple OpenAPI libraries exist for Elixir, they all feel intrusive in some way or another. The goal of Swagdox is to
make the API specifications unobtrusive and simple. This is achieved by having the API be specified in the function docs,
using a similar syntax to Swaggeryard. The primary motivator for this is that our eyes tend to gloss over comments and documentation
unless we are actively trying to read it, and the code doesn't feel cluttered. We even have a precedent for this behaviour in ExDocs!

## Generating

The specification file can be generated in yaml or json format using the `swagdox.generate` mix task. The command line options are as follows:

- `--output` - (required) The path to write the output file.
- `--format` - The format of the output file. Default is `json`.
- `--title` - The title of the API.
- `--version` - The version of the API.
- `--description` - The description of the API.
- `--servers` - The servers of the API.
- `--router` - The router module to use.

All options can alternatively be specified using standard shorthand syntax (`-o`, `-f` etc.)

## Configuration

Swagdox configuration can be set in the project setup in `mix.exs`, using the following configuration options:

```elixir
def project do
  [
    swagdox: [
      router: MyAppWeb.Router,
      format: "yaml",
      output: "./openapi.yml",
      title: "My App",
      version: "1.0",
      description: "A longer description"
    ]
  ]
end
```

Alternatively, any and all of these options can be set via command line arguments:

```bash
mix swagdox.generate -o ./openapi.yml -f yaml -v 1.0 -t "My App" -d "A longer description" -s "localhost://4001,my-app.my-domain.com" -r MyAppWeb.Router
```

## Specification

### API

Specifying the API for a controller endpoint is similar to specifying examples for ExDoc:

```elixir
defmodule MyApp.UserController do

  @doc """
  Returns a User.

  [Swagdox] API:
    @param id(query), integer, "User ID", required: true

    @response 200, User, "User found"
    @response 403, "User not authorized"
    @response 404, "User not found"
  """
  @spec show(any(), map()) :: nil
  def show(_conn, _params) do
    ...
  end
end
```

The above example shows how we can describe parameters and responses. The `[Swagdox] API:` tag is what signals
a specification.

#### Parameters

Parameter specifications must follow the format:

```elixir
@param name(in), type, description, kwargs
```

where `kwargs` is a keyword-list of additional arguments used by OpenAPI specs.

#### Responses

Response are described similarly, and must follow one of these formats:

```elixir
@response code, type, description

@response code, description
```

#### Types

For both parameters and responses, the type of the variable can be defined either as a
standard type or as a schema. Basic types include:

- `integer`
- `number`
- `string`
- `boolean`
- `array`
- `object`

Schemas (described below) are well-defined objects, identified by the fact that they always start with an upper-case letter.
Arrays of types can be specified using the `[]` notation:

```elixir
@response 200, [User], ...
```

### Schemas

Swagdox schemas can be defined by adding a schema definition to the moduledocs.
The definition must include a name, and can include one or more properties which
should have the name, type, and optional description.

```elixir
defmodule Swagdox.Order do
  @mouledoc """
  Some description

  [Swagdox] Schema:
    @name Order
    @property item, string, "The item name"
    @property number, integer, "The number of items ordered"
  """
end
```

Schemas are detected automatically based on the `[Swagdox] Schema:` tag.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `swagdox` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:swagdox, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/swagdox>.
