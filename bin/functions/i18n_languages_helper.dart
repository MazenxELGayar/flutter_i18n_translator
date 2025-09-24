part of "../app.dart";

abstract class I18nLanguageHelper {
  /// Loads i18n config from file and parses into I18nConfig
  static Future<I18nConfig?> loadI18nConfig() async {
    final configFilePath = '${Directory.current.path}/i18nconfig.json';
    final configFile = File(configFilePath);

    if (!configFile.existsSync()) {
      i18PrintError('❌ Configuration file not found!');
      i18PrintError('Expected path: $configFilePath');
      exit(1);
    }

    Map<String, dynamic> json;
    try {
      json =
          jsonDecode(await configFile.readAsString()) as Map<String, dynamic>;
    } catch (e) {
      i18PrintError('❌ Failed to parse i18nconfig.json: $e');
      exit(1);
    }

    final config = I18nConfig.fromJson(json);

    // Ensure localePath exists

    i18PrintDebug('✅ Loaded i18n configuration successfully.');
    i18PrintDebug('Default Locale: ${config.defaultLocale.localeString}');
    i18PrintDebug(
      'Locales: ${config.locales.map((e) => e.localeString).join(", ")}',
    );
    i18PrintDebug('Locale Path: ${config.localeDirectory.path}');

    return config;
  }

  /// Recursively finds keys in `source` that are missing in `target`.
  static Map<String, dynamic> findMissingKeysWithPath(
    Map<String, dynamic> source,
    Map<String, dynamic> target, [
    String parentPath = '',
  ]) {
    final Map<String, dynamic> missing = {};

    source.forEach((key, value) {
      final currentPath = parentPath.isEmpty ? key : '$parentPath.$key';

      if (!target.containsKey(key) ||
          value.runtimeType != target[key].runtimeType) {
        // Key completely missing
        missing[currentPath] = value;
      } else if (value is Map<String, dynamic> && target[key] is Map) {
        // Both are maps → recurse
        final nestedMissing = findMissingKeysWithPath(
          value,
          target[key] as Map<String, dynamic>,
          currentPath,
        );
        missing.addAll(nestedMissing);
      }
    });

    return missing;
  }


}
