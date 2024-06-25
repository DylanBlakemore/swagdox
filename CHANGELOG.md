# Changelog

## [0.1.0] - 26 May 2024

### First release

- Generate OpenAPI specification using `swagdox.generate` task
- Add authentication in Router moduledoc
- Describe models in moduledocs of schemas
  - Models are automatically detected by presence of `[Swagdox] Schema:` tag
- Describe endpoints using function docs
  - Controllers are detected by defining the router module
  - Endpoints are detected within the controller by the presence of `[Swagdox] API:` tag

## [0.1.1] - 21 June 2024

### Documentation improvements

- Add ReadMe, Changelog, and License to docs
- Redirect docs to Readme

## [0.1.2] - 21 June 2024

### Documentation fix

- Fix reference to readme html

## [0.1.3] - 26 June 2024

### Paramater fix

- Fix parameter array types
