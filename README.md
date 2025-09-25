Perfect 👍 Here’s the updated **README.md** with a clear note about requiring `i18n_json` when using `--autoGenerate`:

````markdown
# flutter_i18n_translator

[![pub package](https://img.shields.io/pub/v/flutter_i18n_translator.svg)](https://pub.dev/packages/flutter_i18n_translator)

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
- **Auto-generate Dart i18n files** using [`i18n_json`](https://pub.dev/packages/i18n_json).

---

## 📦 Installation

Activate globally from [pub.dev](https://pub.dev/packages/flutter_i18n_translator):

```bash
dart pub global activate flutter_i18n_translator
````

Or use locally in a project:

```yaml
dev_dependencies:
  flutter_i18n_translator: ^0.1.1
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
    "fr-FR",
    "ar-EG"
  ],
  "localePath": "i18n"
}
```

* `defaultLocale`: The base locale with full translations.
* `locales`: List of all locales you support.
* `localePath`: Directory where JSON files are stored.

Example structure:

```
project_root/
  i18n/
    en-US.json
    fr-FR.json
    ar-EG.json
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
--help, -h                     Show this help message
```

⚠️ **Note:** To use `--autoGenerate`, you must add [`i18n_json`](https://pub.dev/packages/i18n_json) to your project:

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