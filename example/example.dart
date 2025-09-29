import 'dart:io';

/// Example usage of flutter_i18n_translator CLI.
///
/// These examples show how to run the tool with different flags.
/// Normally you would run these commands from your project root.
///
/// Example i18nconfig.json:
/// ```json
/// {
///   "defaultLocale": "en-US",
///   "locales": [
///     "en-US",
///     "fr-FR",
///     "ar-EG"
///   ],
///   "localePath": "i18n"
/// }
/// ```
///
/// Example directory structure:
/// ```
/// project_root/
///   i18n/
///     en-US.json
///     fr-FR.json
///     ar-EG.json
///   i18nconfig.json
/// ```

Future<void> main() async {
  print('🚀 flutter_i18n_translator examples');

  // 1️⃣ Show CLI help
  await _runExample(['--help'], description: 'Show CLI help');

  // 2️⃣ Translate missing keys with defaults
  await _runExample([], description: 'Translate with default settings');

  // 3️⃣ Auto-translate and apply translations without confirmation
  await _runExample(
    ['--auto-translate', '--auto_apply-translations'],
    description: 'Auto-translate and apply without prompts',
  );

  // 4️⃣ Use a smaller batch size
  await _runExample(
    ['--batch-limit', '1000'],
    description: 'Set smaller batch size (1000 chars)',
  );

  // 5️⃣ Disable debug logs
  await _runExample(
    ['--no-debug'],
    description: 'Run silently without debug logs',
  );

  // 6️⃣ Enable debug logs
  await _runExample(
    ['--show-debug'],
    description: 'Enable debug logging',
  );

  // 7️⃣ Auto-generate Dart i18n helpers (requires i18n_json dependency)
  await _runExample(
    ['--autoGenerate'],
    description: 'Translate and regenerate Dart files using i18n_json',
  );

  // 8️⃣ Explicitly disable auto-generation
  await _runExample(
    ['--no-autoGenerate'],
    description: 'Translate without generating Dart files',
  );

  // 9️⃣ Ensure WidgetsLocalizations overrides are added
  await _runExample(
    ['--addMissingOverrides'],
    description: 'Add missing WidgetsLocalizations overrides to I18n',
  );

  // 🔟 Disable adding WidgetsLocalizations overrides
  await _runExample(
    ['--no-addMissingOverrides'],
    description: 'Do not add WidgetsLocalizations overrides to I18n',
  );

  // 1️⃣1️⃣ Convert keys to camelCase
  await _runExample(
    ['--key-case', 'camel'],
    description: 'Convert all JSON keys to camelCase',
  );

  // 1️⃣2️⃣ Convert keys to PascalCase
  await _runExample(
    ['--key-case', 'pascal'],
    description: 'Convert all JSON keys to PascalCase',
  );

  // 1️⃣3️⃣ Convert keys to snake_case
  await _runExample(
    ['--key-case', 'snake'],
    description: 'Convert all JSON keys to snake_case',
  );

  // 1️⃣4️⃣ Convert keys to kebab-case
  await _runExample(
    ['--key-case', 'kebab'],
    description: 'Convert all JSON keys to kebab-case',
  );

  // 1️⃣5️⃣ Enhance generated I18n file
  await _runExample(
    ['--enhanceGeneratedFile'],
    description:
        'Enhances the generated I18n file (adds locale setter & static current instance without the need of context)',
  );
}

Future<void> _runExample(List<String> args,
    {required String description}) async {
  print('\n👉 $description');
  print('   Command: dart run flutter_i18n_translator ${args.join(" ")}\n');

  final result = await Process.run(
    'dart',
    ['run', 'flutter_i18n_translator', ...args],
  );

  print('Exit code: ${result.exitCode}');
  if (result.stdout.toString().isNotEmpty) {
    print('--- STDOUT ---\n${result.stdout}');
  }
  if (result.stderr.toString().isNotEmpty) {
    print('--- STDERR ---\n${result.stderr}');
  }
}
