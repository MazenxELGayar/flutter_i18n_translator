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

  static Future<void> postProcessI18nJson(I18nConfig config) async {
    if (addMissingOverridesGeneratedFile == false &&
        replaceLocaleSetter == false) {
      i18PrintDebug("No Post Process, Everything is false");
      return;
    }
    final file = File('${config.generatedDirectory.path}/i18n.dart');

    if (!await file.exists()) {
      i18PrintError(
          "⚠️ i18n.dart not found in ${config.generatedDirectory.path}");
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

    // --- build the locale setter + lookup function if replaceLocaleSetter is true ---
    if (replaceLocaleSetter) {
      final switchCases = config.locales.map((localeFile) {
        final locale = localeFile.locale;
        final key = locale.countryCode != null
            ? '${locale.languageCode}_${locale.countryCode}'
            : locale.languageCode;

        final className = [
          '_I18n',
          locale.languageCode,
          if (locale.countryCode != null) locale.countryCode,
        ].join('_').replaceAll('-', '_');

        return '      case "$key":\n        return const $className();';
      }).join('\n');

      final replacementSetter = '''
  static I18n? _current;
  static I18n? get current => _current;

  static set locale(Locale? newLocale) {
    _shouldReload = true;
    I18n._locale = newLocale;
    if (_locale != null) {
      onLocaleChanged?.call(_locale!);
    }
    _current = _lookupI18n(newLocale);
  }

  static I18n _lookupI18n(Locale? locale) {
    if (locale == null) {
      return const I18n();
    }
final key = locale.countryCode != null
    ? locale.languageCode + '_' + locale.countryCode!
    : locale.languageCode;

  switch (key) {
$switchCases
      default:
        if (kDebugMode) {
          print("⚠️ Unknown locale: \$locale");
        }
        return const I18n(); // fallback
    }
  }
''';

      // Replace the old setter completely
      final localeSetterRegex = RegExp(
        r'static set locale\(Locale\? newLocale\)\s*\{[\s\S]*?\}',
        multiLine: true,
      );

      if (localeSetterRegex.hasMatch(i18nBody)) {
        i18nBody = i18nBody.replaceFirst(localeSetterRegex, replacementSetter);
      } else {
        // if not found, just append at end of class
        i18nBody += '\n$replacementSetter\n';
      }
    }

    // --- Inject missing WidgetsLocalizations overrides (conditional) ---
    if (addMissingOverridesGeneratedFile) {
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

      requiredOverrides.forEach((name, code) {
        if (!i18nBody.contains(name)) {
          i18nBody += '\n  @override\n  $code\n';
        }
      });
    }

    // Rebuild full file content
    final patched = content.replaceFirst(
      i18nClassRegex,
      'class I18n implements WidgetsLocalizations {\n$i18nBody\n}',
    );

    await file.writeAsString(patched);
    i18PrintNormal(
      "✅ Patched I18n class with locale setter & missing overrides",
      writeLine: true,
    );
  }

  static Future<void> fixGeneratedFiles(String path) async {
    // 1️⃣ Apply dart fix
    final fixResult = await Process.run(
      'dart',
      ['fix', '--apply', path],
    );

    if (fixResult.exitCode == 0) {
      i18PrintNormal(
        '✅ Dart fix applied successfully in $path',
        writeLine: true,
      );
      i18PrintDebug("output: ${fixResult.stdout}");
    } else {
      i18PrintError('❌ Dart fix failed:\n${fixResult.stderr}');
    }

    // 2️⃣ Format with dart format
    final formatResult = await Process.run(
      'dart',
      ['format', path],
    );

    if (formatResult.exitCode == 0) {
      i18PrintNormal(
        '✅ Dart format applied successfully in $path',
        writeLine: true,
      );
      i18PrintDebug("output: ${formatResult.stdout}");
    } else {
      i18PrintError('❌ Dart format failed:\n${formatResult.stderr}');
    }
  }
}
