![CI Pipeline](https://github.com/dylanblakemore/swagdox/actions/workflows/elixir.yml/badge.svg)
# Swagdox

Swagdox is a Swagger/OpenAPI specification generator inspired by [Swaggeryard](https://github.com/livingsocial/swagger_yard).

While multiple OpenAPI libraries exist for Elixir, they all feel intrusive in some way or another. The goal of Swagdox is to
make the API specifications unobtrusive and simple. This is achieved by having the API be specified in the function docs,
using a similar syntax to Swaggeryard. The primary motivator for this is that our eyes tend to gloss over comments and documentation
unless we are actively trying to read it, and the code doesn't feel cluttered. We even have a precedent for this behaviour in ExDocs!

## Configuration

## Specification

### API

### Schemas

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

