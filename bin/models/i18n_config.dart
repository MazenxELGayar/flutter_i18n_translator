part of '../app.dart';

/// Model class for i18n configuration
class I18nConfig {
  final I18nLocaleFile defaultLocale;
  final Set<I18nLocaleFile> locales;
  final Directory localeDirectory;
  final Directory generatedDirectory;

  I18nConfig({
    required this.defaultLocale,
    required this.locales,
    required this.localeDirectory,
    required this.generatedDirectory,
  });

  /// Parse raw JSON into I18nConfig
  factory I18nConfig.fromJson(Map<String, dynamic> json) {
    /// Locale directory
    final localePathStr = json['localePath'] as String? ?? 'i18n';
    final localeDir = Directory(localePathStr);
    if (!localeDir.existsSync()) {
      i18PrintDebug('📂 Creating missing locale directory: $localePathStr');
      localeDir.createSync(recursive: true);
    }

    final generatedPathStr =
        json['generatedDirectory'] as String? ?? "lib/generated";
    final generatedDir = Directory(generatedPathStr);
    if (!generatedDir.existsSync()) {
      i18PrintDebug(
          '📂 Creating missing Generated directory: $generatedPathStr');
      generatedDir.createSync(recursive: true);
    }

    /// ************************************************************************
    final defaultLocalesList = {
      "en-US",
      "ar-EG",
      "fr-FR",
      "es-ES",
      "de-DE",
      "it-IT",
      "ru-RU",
      "zh-CN",
      "ja-JP",
      "ko-KR",
      "pt-PT",
      "hi-IN",
      "tr-TR",
    };

    // Default locale: take from config, or first of locales
    final defaultLocaleString = json['defaultLocale'] as String?;
    // LTR and RTL
    Set<String> ltr = {};
    if (json['ltr'] != null && json['ltr'] is List) {
      ltr = Set<String>.from(json['ltr']);
    }

    Set<String> rtl = {};
    if (json['rtl'] != null && json['rtl'] is List) {
      rtl = Set<String>.from(json['rtl']);
    }

    I18nLocaleFile? defaultLocale;

    // Parse locales list
    Set<String> rawLocales = {};
    if (json['locales'] != null &&
        json['locales'] is List &&
        (json['locales'] as List).isNotEmpty) {
      rawLocales = Set<String>.from(json['locales']);
    } else {
      rawLocales = defaultLocalesList;
    }

    final locales = rawLocales.map((locale) {
      final localeFile = I18nLocaleFile.generateLocaleFile(
        locale: _parseLocale(locale),
        localeDirectory: localeDir,
        ltrLocales: ltr,
        rtlLocales: rtl,
      );
      if (locale == defaultLocaleString) {
        defaultLocale = localeFile;
      }
      return localeFile;
    }).toSet();

    defaultLocale ??= locales.first;

    return I18nConfig(
      defaultLocale: defaultLocale!,
      locales: locales,
      localeDirectory: localeDir,
      generatedDirectory: generatedDir,
    );
  }

  static I18nLocale _parseLocale(String localeStr) {
    late final I18nLocale locale;
    final parts = localeStr.split('-');
    if (parts.length == 2) {
      locale = I18nLocale(parts[0], parts[1]);
    } else {
      locale = I18nLocale(localeStr);
    }
    return locale;
  }
}
