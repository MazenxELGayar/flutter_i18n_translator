part of '../app.dart';

/// Represents a locale and its associated JSON file
class I18nLocaleFile {
  final I18nLocale locale;
  final File file;
  Map<String, dynamic> jsonContent;
  final TextDirection direction;

  I18nLocaleFile({
    required this.locale,
    required this.file,
    Map<String, dynamic>? jsonContent,
    this.direction = TextDirection.ltr,
  }) : jsonContent = jsonContent ?? {};

  String get localeString => localeToString(locale);

  static String localeToString(I18nLocale locale) =>
      "${locale.languageCode}${(locale.countryCode?.isNotEmpty ?? false) ? "-${locale.countryCode}" : ""}";

  /// Loads the JSON content from the file, or creates empty if file doesn't exist
  void loadOrCreate() {
    if (file.existsSync()) {
      try {
        jsonContent = jsonDecode(file.readAsStringSync());
      } catch (_) {
        i18PrintError('⚠️ Failed to parse ${file.path}, starting with empty.');
        jsonContent = {};
      }
    } else {
      i18PrintDebug('📄 Creating new locale file: ${file.path}');
      file.createSync(recursive: true);
      jsonContent = {};
      save();
    }
  }

  /// Save current JSON content back to file
  void save() {
    file.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(jsonContent),
    );
  }

  /// Given an I18nConfig, returns a list of LocaleFile for all locales
  static I18nLocaleFile generateLocaleFile({
    required I18nLocale locale,
    required Directory localeDirectory,
    required Set<String> ltrLocales,
    required Set<String> rtlLocales,
  }) {
    final localeString = localeToString(locale);
    final localeFileName = "$localeString.json";

    final file = File('${localeDirectory.path}/$localeFileName');
    TextDirection direction;
    if (rtlLocales.contains(localeString)) {
      direction = TextDirection.rtl;
    } else {
      direction = TextDirection.ltr;
    }
    final localeFile = I18nLocaleFile(
      locale: locale,
      file: file,
      direction: direction,
    );
    localeFile.loadOrCreate();
    return localeFile;
  }

  /// Add or replace entries in jsonContent recursively
  void addOrReplaceEntries(Map<String, dynamic> newEntries) {
    void merge(Map<String, dynamic> target, Map<String, dynamic> source) {
      source.forEach((key, value) {
        if (value is Map<String, dynamic> &&
            target[key] is Map<String, dynamic>) {
          merge(target[key], value);
        } else {
          target[key] = value;
        }
      });
    }

    merge(jsonContent, newEntries);
  }

  /// Equality based on locale
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is I18nLocaleFile &&
          runtimeType == other.runtimeType &&
          locale.languageCode == other.locale.languageCode &&
          locale.countryCode == other.locale.countryCode;

  @override
  int get hashCode =>
      locale.languageCode.hashCode ^ (locale.countryCode?.hashCode ?? 0);
}
