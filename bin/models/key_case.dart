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
  /// Converts any string to camelCase
  static String _toCamelCase(String input) {
    final parts = _splitToWords(input);
    if (parts.isEmpty) return '';
    return parts.first.toLowerCase() +
        parts.skip(1).map((w) => _capitalize(w)).join();
  }

  /// Converts any string to PascalCase
  static String _toPascalCase(String input) {
    final parts = _splitToWords(input);
    return parts.map((w) => _capitalize(w)).join();
  }

  /// Converts any string to snake_case
  static String _toSnakeCase(String input) {
    final parts = _splitToWords(input);
    return parts.map((w) => w.toLowerCase()).join('_');
  }

  /// Converts any string to kebab-case
  static String _toKebabCase(String input) {
    final parts = _splitToWords(input);
    return parts.map((w) => w.toLowerCase()).join('-');
  }

  /// --- Helper methods ---

  /// Splits input into words based on _ - space or camel/PascalCase boundaries
  static List<String> _splitToWords(String input) {
    if (input.isEmpty) return [];

    // Step 1: replace non-alphanumeric separators with spaces
    final normalized = input.replaceAll(RegExp(r'[_\-\s]+'), ' ');

    // Step 2: insert spaces before uppercase letters (camel/PascalCase)
    final splitCamel = normalized.replaceAllMapped(
      RegExp(r'([a-z0-9])([A-Z])'),
      (m) => '${m[1]} ${m[2]}',
    );

    // Step 3: split by space and remove empty parts
    return splitCamel
        .split(' ')
        .map((w) => w.trim())
        .where((w) => w.isNotEmpty)
        .toList();
  }

  /// Capitalize first letter, preserve rest
  static String _capitalize(String word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
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
