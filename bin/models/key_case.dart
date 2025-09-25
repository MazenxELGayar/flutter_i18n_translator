part of "../app.dart";

enum I18nKeyCase {
  camel(
    _toCamelCase,
    aliases: [
      'camel',
      'camelcase',
      'camel_case',
    ],
  ),
  pascal(
    _toPascalCase,
    aliases: [
      'pascal',
      'pascalcase',
      'pascal_case',
      'uppercamel',
      'upper_camel',
    ],
  ),
  snake(
    _toSnakeCase,
    aliases: [
      'snake',
      'snakecase',
      'snake_case',
      'underscore',
    ],
  ),
  kebab(
    _toKebabCase,
    aliases: [
      'kebab',
      'kebabcase',
      'kebab_case',
      'kebab-case',
      'dash',
      'dashcase',
    ],
  );

  final String Function(String) _converter;
  final List<String> aliases;

  const I18nKeyCase(this._converter, {this.aliases = const []});

  /// Convert a string to [I18nKeyCase], returns null if not recognized
  static I18nKeyCase? fromString(String? style) {
    if (style == null) return null;
    final normalized = style.toLowerCase();

    for (final keyCase in I18nKeyCase.values) {
      if (keyCase.aliases.contains(normalized)) {
        return keyCase;
      }
    }
    i18PrintError(
      "Error: --key-case values must be one of (camel, pascal, snake, kebab)",
    );
    exit(1);
  }

  /// Convert a key string based on this [I18nKeyCase]
  String convert(String input) => _converter(input);

  // ---- private converters ----
  static String _toCamelCase(String input) {
    // Split on _, -, spaces
    final parts = input.split(RegExp(r'[_\s-]+'));

    // If only one part, preserve internal capitals
    if (parts.length == 1) {
      final p = parts.first;
      return p[0].toLowerCase() + p.substring(1);
    }

    final newValue = parts.first.toLowerCase() +
        parts
            .skip(1)
            .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
            .join();

    i18PrintDebug("$input => $newValue");
    return newValue;
  }


  static String _toPascalCase(String input) {
    final parts = input.split(RegExp(r'[_\s-]+'));
    return parts
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join();
  }

  static String _toSnakeCase(String input) {
    return input
        .replaceAllMapped(
            RegExp(r'[A-Z]'), (m) => '_${m.group(0)!.toLowerCase()}')
        .replaceAll(RegExp(r'[\s-]+'), '_')
        .toLowerCase()
        .replaceFirst(RegExp(r'^_+'), '');
  }

  static String _toKebabCase(String input) {
    return input
        .replaceAllMapped(
            RegExp(r'[A-Z]'), (m) => '-${m.group(0)!.toLowerCase()}')
        .replaceAll(RegExp(r'[\s_]+'), '-')
        .toLowerCase()
        .replaceFirst(RegExp(r'^-+'), '');
  }
}

extension LocaleFileConverted on I18nLocaleFile {
  /// Convert all keys in this locale file to the given case and save to disk
  Future<void> convertAllKeys() async {
    try {
      jsonContent = _convertMapKeys(jsonContent);
      await file.writeAsString(
          const JsonEncoder.withIndent("  ").convert(jsonContent));
    } catch (e) {
      i18PrintError(
        "Error converting $localeString keys: $e",
      );
    }
  }

  Map<String, dynamic> _convertMapKeys(
    Map<String, dynamic> original,
  ) {
    final result = <String, dynamic>{};
    original.forEach((key, value) {
      final newKey = keyCase!.convert(key);
      if (value is Map<String, dynamic>) {
        result[newKey] = _convertMapKeys(value);
      } else if (value is List) {
        result[newKey] = _convertList(value);
      } else {
        result[newKey] = value;
      }
    });
    return result;
  }

  dynamic _convertList(List<dynamic> list) {
    return list.map((e) {
      if (e is Map<String, dynamic>) {
        return _convertMapKeys(e);
      } else if (e is List) {
        return _convertList(e);
      } else {
        return e;
      }
    }).toList();
  }
}
