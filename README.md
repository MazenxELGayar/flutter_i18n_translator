# i18n_translator

[![pub package](https://img.shields.io/pub/v/flutter_i18n_translator)](https://pub.dev/packages/flutter_i18n_translator)

A CLI tool to automatically translate missing keys in JSON localization files for Flutter/Dart projects.  
It uses [translator](https://pub.dev/packages/translator) under the hood (Google Translate API).

---

## ✨ Features
- Detects missing keys in your i18n JSON files.
- Translates missing entries using Google Translate.
- Supports batching with character limits.
- Placeholders (`{digit}`, `{name}`, etc.) are preserved during translation.
- Configurable via `i18nconfig.json`.
- CLI flags to enable automation & debug logging.

---

## 📦 Installation

Activate globally from [pub.dev](https://pub.dev/packages/flutter_i18n_translator):

```bash
dart pub global activate i18n_translator
