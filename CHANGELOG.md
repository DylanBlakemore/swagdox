# Changelog

## [Unreleased]

### Features

- Lift `required: true` on a `@property` into the schema object's `required` array, instead of
  silently dropping it.
- Expose the target OpenAPI version through the `--openapi-version` mix task flag and the
  `:openapi_version` project config, making the existing 3.1.x rendering reachable.
- Emit document-level `tags` aggregated from the tags used across operations.
- Add standalone `@example` and `@header` tags (keyed by status code) for documenting response
  examples and response headers. Headers are modelled by a `Swagdox.Header` struct and rendered
  through `Swagdox.Type`, so their schemas honor the configured OpenAPI version.
- Support union and polymorphic types. A union is written with `|` (`Cat | Dog`) and renders as
  `oneOf`; `any_of(...)` and `all_of(...)` cover the remaining JSON Schema composition keywords.
  Unions work anywhere a type does - `@param`, `@property`, `@response`, `@header` - and nest
  inside the array notation (`[Cat | Dog]`).
- Add a `discriminator` option to compositions, accepting either a property name or
  `[property: ..., mapping: %{...}]`. Bare schema names in a mapping are expanded to component
  references.
- Add the schema-level `@type` tag, so a named schema can be a composition
  (`@type Cat | Dog`) rather than a property bag, optionally with a `@discriminator`. A composed
  schema that also documents properties renders both, covering the `allOf`-plus-own-fields
  inheritance shape.

### Fixes

- Render response schemas at render time, so a `@response`'s schema honors the configured
  `openapi_version` (previously it was always rendered as 3.0). Schema constraints in a
  `@response`'s trailing options (`nullable`, `discriminator`, ...) now reach the schema instead
  of being dropped; options that describe the response itself are left untouched.

## [0.3.0] - 08 June 2026

### Features

- Add constraint options to the `@param` and `@property` DSL: `enum`, `nullable`, `format`,
  `min_length`/`max_length`, `minimum`/`maximum`, `pattern`, and `min_items`/`max_items`.
  Scalar constraints apply to array items; `min_items`/`max_items` apply to the array. Nullable
  rendering follows the configured `openapi_version` (`nullable: true` for 3.0, a `"null"` type
  union for 3.1) ([#1](https://github.com/DylanBlakemore/swagdox/issues/1)).

### Fixes

- De-duplicate `operationId`s so the spec stays OpenAPI-valid when one action serves
  multiple routes (e.g. `resources` PUT/PATCH update twins or dual-mounted controllers).
  Colliding ids are disambiguated by verb, then by path; already-unique ids are unchanged
  ([#2](https://github.com/DylanBlakemore/swagdox/issues/2)).

## [0.2.1] - 13 November 2025

- Adds request body parameters to spec

## [0.2.0] - 09 February 2025

### Tags and Schema examples

- Adds the ability to tag endpoints using the `@tag` syntax
- Adds the ability to provide an example for a schema using `@example` syntax

## [0.1.3] - 26 June 2024

### Paramater fix

- Fix parameter array types

## [0.1.2] - 21 June 2024

### Documentation fix

- Fix reference to readme html

## [0.1.1] - 21 June 2024

### Documentation improvements

- Add ReadMe, Changelog, and License to docs
- Redirect docs to Readme

## [0.1.0] - 26 May 2024

### First release

- Generate OpenAPI specification using `swagdox.generate` task
- Add authentication in Router moduledoc
- Describe models in moduledocs of schemas
  - Models are automatically detected by presence of `[Swagdox] Schema:` tag
- Describe endpoints using function docs
  - Controllers are detected by defining the router module
  - Endpoints are detected within the controller by the presence of `[Swagdox] API:` tag






