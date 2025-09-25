# Changelog

All notable changes to this project will be documented in this file.

## 0.1.4 - 2025-09-25
### Added
- `--key-case` flag to automatically convert all JSON keys to a specific case.
- Supported key case styles:
  - `camel`, `camelcase`, `camel_case` → camelCase
  - `pascal`, `pascalcase`, `pascal_case` → PascalCase
  - `snake`, `snakecase`, `snake_case` → snake_case
  - `kebab`, `kebabcase`, `kebab_case`, `dash`, `dashcase`, `dash_case` → kebab-case
- New examples in `example.dart` for each `--key-case` style.
- Updated README with `--key-case` documentation.

### Changed
- Updated CLI help to show all supported `--key-case` options.

## 0.1.3 - 2025-09-25
### Added
- `--autoGenerate` flag to automatically regenerate i18n files (runs `dart run i18n_json`).
- `--no-autoGenerate` flag to explicitly disable automatic generation.
- `--addMissingOverrides` flag to ensure missing `WidgetsLocalizations` overrides are injected into the root `I18n` class after generation.
- `--no-addMissingOverrides` flag to skip injecting missing overrides.

### Changed
- Updated CLI help message to include the new options.

## 0.1.0 - 2025-09-24
- Initial release of **i18n_translator** CLI tool.
- Features:
  - Detects missing keys in JSON localization files.
  - Supports automatic translation using Google Translator.
  - Allows batching translations with a configurable character limit.
  - Options to auto-translate and apply without manual confirmation.
  - Debug logging with `--show-debug` and `--no-debug`.
  - CLI help with `--help`.
