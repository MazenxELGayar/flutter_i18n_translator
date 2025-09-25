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

  static Future<void> postProcessI18nJson(String generatedDir) async {
    final file = File('$generatedDir/i18n.dart');

    if (!await file.exists()) {
      i18PrintError("⚠️ i18n.dart not found in $generatedDir");
      return;
    }

    var content = await file.readAsString();

    // Extract only the root I18n class (first match)
    final i18nClassRegex = RegExp(
      r'class I18n implements WidgetsLocalizations[^{]*\{([\s\S]*?)\n\}',
      multiLine: true,
    );

    final match = i18nClassRegex.firstMatch(content);
    if (match == null) {
      i18PrintError("⚠️ Could not find I18n class in i18n.dart");
      return;
    }

    var i18nBody = match.group(1)!;

    // Required overrides
    final requiredOverrides = <String, String>{
      'copyButtonLabel': 'String get copyButtonLabel => "Copy";',
      'cutButtonLabel': 'String get cutButtonLabel => "Cut";',
      'lookUpButtonLabel': 'String get lookUpButtonLabel => "Look up";',
      'pasteButtonLabel': 'String get pasteButtonLabel => "Paste";',
      'searchWebButtonLabel':
          'String get searchWebButtonLabel => "Search Web";',
      'selectAllButtonLabel':
          'String get selectAllButtonLabel => "Select All";',
      'shareButtonLabel': 'String get shareButtonLabel => "Share";',
    };

    // Inject only missing ones into the I18n class body
    requiredOverrides.forEach((name, code) {
      if (!i18nBody.contains(name)) {
        i18nBody += '\n  @override\n  $code\n';
      }
    });

    // Rebuild full file content
    final patched = content.replaceFirst(
      i18nClassRegex,
      'class I18n implements WidgetsLocalizations {\n$i18nBody\n}',
    );

    await file.writeAsString(patched);
    i18PrintNormal(
      "✅ Patched I18n class with missing WidgetsLocalizations overrides",
      writeLine: true,
    );
  }

  static Future<void> fixGeneratedFiles(String path) async {
    final result = await Process.run(
      'dart',
      ['fix', '--apply', path],
    );

    if (result.exitCode == 0) {
      i18PrintNormal(
        '✅ Dart fix applied successfully in $path',
        writeLine: true,
      );
      i18PrintDebug("output: ${result.stdout}");
    } else {
      i18PrintError('❌ Dart fix failed:\n${result.stderr}');
    }
  }
}
