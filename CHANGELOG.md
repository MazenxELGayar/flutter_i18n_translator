# Changelog

All notable changes to this project will be documented in this file.

## 0.1.1 - 2025-09-25
### Added
- `--autoGenerate` flag to automatically regenerate i18n files (runs `dart run i18n_json`).
- `--no-autoGenerate` flag to explicitly disable automatic generation.
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
