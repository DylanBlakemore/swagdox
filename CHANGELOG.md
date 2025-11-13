# Changelog

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






