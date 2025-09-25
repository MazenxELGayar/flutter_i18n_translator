# flutter_i18n_translator

[![pub package](https://img.shields.io/pub/v/flutter_i18n_translator.svg)](https://pub.dev/packages/flutter_i18n_translator)

A CLI tool to automatically translate missing keys in JSON localization files for Flutter/Dart
projects.  
It uses [translator](https://pub.dev/packages/translator) under the hood (Google Translate API).

---

## ✨ Features

- Detects missing keys in your i18n JSON files.
- Translates missing entries using Google Translate.
- Supports batching with character limits.
- Placeholders (`{digit}`, `{name}`, etc.) are preserved during translation.
- Configurable via `i18nconfig.json`.
- CLI flags to enable automation & debug logging.
- **Auto-generate Dart i18n files** using [`i18n_json`](https://pub.dev/packages/i18n_json).
- Convert all JSON keys to a specific case (`camelCase`, `PascalCase`, `snake_case`, `kebab-case`).

---

## 📦 Installation

Activate globally from [pub.dev](https://pub.dev/packages/flutter_i18n_translator):

```bash
dart pub global activate flutter_i18n_translator
````

Or use locally in a project:

```yaml
dev_dependencies:
  flutter_i18n_translator: ^0.1.5
```

Run from project root:

```bash
dart run flutter_i18n_translator
```

---

## ⚙️ Configuration

Create an `i18nconfig.json` in your project root:

```json
{
  "defaultLocale": "en-US",
  "locales": [
    "en-US",
    "ar-EG",
    "fr-FR",
    "es-ES",
    "de-DE",
    "it-IT",
    "ru-RU",
    "ja-JP",
    "ko-KR",
    "pt-PT",
    "hi-IN",
    "tr-TR"
  ],
  "localePath": "i18n",
  "generatedPath": "lib/generated",
  "ltr": [
    "en-US",
    "fr-FR",
    "es-ES",
    "de-DE",
    "it-IT",
    "ru-RU",
    "ja-JP",
    "ko-KR",
    "pt-PT",
    "hi-IN",
    "tr-TR"
  ],
  "rtl": [
    "ar-EG"
  ]
}
```

* `defaultLocale`: The base locale with full translations.
* `locales`: List of all locales you support.
* `localePath`: Directory where JSON files are stored.
* `generatedPath`: Directory where i18n will generate Dart files.
* `ltr`: Locales that are Left to Right.
* `rtl`: Locales that are Right to Left.

Example structure:

```
project_root/
  i18n/
    en-US.json
    fr-FR.json
    ar-EG.json
  lib/
    generated/
      i18n.dart
  i18nconfig.json
```

---

## 🚀 Usage

Run the tool from your project root:

```bash
flutter_i18n_translator
```

### CLI Options

```
--batch-limit <number>         Set max characters per translation batch (default: 3000)
--auto-translate               Automatically send translations without confirmation
--auto_apply-translations      Apply translations without user prompt
--autoGenerate                 Automatically run `dart run i18n_json` to regenerate Dart files
--no-autoGenerate              Disable automatic file generation
--show-debug                   Enable debug messages
--no-debug                     Disable debug messages
--addMissingOverrides          Ensure WidgetsLocalizations overrides are added to I18n
--no-addMissingOverrides       Disable adding WidgetsLocalizations overrides to I18n
--key-case <style>             Convert all JSON keys to a specific case (camel, pascal, snake, kebab)
--help, -h                     Show this help message
```

⚠️ **Note:** To use `--autoGenerate`, you must add [`i18n_json`](https://pub.dev/packages/i18n_json)
to your project:

```yaml
dev_dependencies:
  i18n_json: ^1.0.0
```

---

### Examples

Translate with default options:

```bash
flutter_i18n_translator
```

Set a smaller batch limit:

```bash
flutter_i18n_translator --batch-limit 1000
```

Translate & apply automatically:

```bash
flutter_i18n_translator --auto-translate --auto_apply-translations
```

Translate and regenerate Dart i18n file automatically:

```bash
flutter_i18n_translator --autoGenerate
```

Run silently without debug logs:

```bash
flutter_i18n_translator --no-debug
```

Convert all keys to `snake_case`:

```bash
flutter_i18n_translator --key-case snake
```
---
## ⚡ Android Studio Integration

You can bind the CLI to a keyboard shortcut for faster usage:

1. Go to **File → Settings → Tools → External Tools**.
2. Click **+** to add a new tool:
    - **Name:** `flutter_i18n_translator`
    - **Program:** `dart`
    - **Arguments:** `run flutter_i18n_translator`
        - Or with flags: `run flutter_i18n_translator --auto-translate --auto_apply-translations`
    - **Working directory:** `$ProjectFileDir$`
3. Save and close.
4. Now go to **File → Settings → Keymap**.
5. Search for your tool name (`flutter_i18n_translator`), right-click → **Add Keyboard Shortcut**, and assign your preferred key combo.
6. You can now run translations directly with your shortcut inside Android Studio 🎉

---

## 🛠 Development

Clone the repo:

```bash
git clone https://github.com/MazenxELGayar/flutter_i18n_translator.git
cd flutter_i18n_translator
```

Run locally:

```bash
dart run bin/flutter_i18n_translator.dart --help
```

---

## 📄 License

MIT License © 2025 [Mazen El-Gayar](https://github.com/MazenxELGayar)