import 'dart:convert';
import 'dart:io';

import 'package:translator/translator.dart';

import 'functions/i18n_pretty_map.dart';

part "functions/i18n_languages_helper.dart";

part "functions/i18n_print.dart";

part "functions/i18n_translation_helper.dart";

part "models/i18n_config.dart";

part 'models/i18n_locale.dart';

part "models/i18n_locale_file.dart";

part 'models/text_direction.dart';

part 'models/key_case.dart';

// Default CLI options
int charBatchLimit = 3000;
bool autoTranslate = false;
bool autoApplyTranslations = false;
bool showDebug = false;
bool autoGenerate = true;
bool autoDartFixGeneratedFile = true;
bool replaceLocaleSetter = true;
bool addMissingOverridesGeneratedFile = true;
I18nKeyCase? keyCase;

void runTranslator(List<String> args) async {
  processArgs(
    args,
  );
  i18PrintDebug("Loading I18n Configurations...");
  final I18nConfig? config = await I18nLanguageHelper.loadI18nConfig();
  if (config == null) {
    i18PrintError('❌ Failed to load i18n configuration.');
    exit(1);
  } else {
    i18PrintDebug("I18n Configurations was parsed Successfully!");
  }
  if (keyCase != null) {
    config.defaultLocale.convertAllKeys();
  }
  // Exclude the default locale
  final localesWithoutDefault =
      config.locales.where((locale) => locale != config.defaultLocale).toSet();

  if (localesWithoutDefault.isEmpty) {
    i18PrintError('❌ No locales to translate.');
    exit(1);
  } else {
    i18PrintNormal(
      "Locales To Translate: "
      "${localesWithoutDefault.map((e) => e.localeString).join(", ")}",
      writeLine: true,
    );
  }

  for (I18nLocaleFile localeFile in localesWithoutDefault) {
    if (keyCase != null) {
      localeFile.convertAllKeys();
    }
    i18PrintDebug('**********************************************************\n'
        'Fetching Missing Keys for ${localeFile.localeString}...');
    final missing = I18nLanguageHelper.findMissingKeysWithPath(
      config.defaultLocale.jsonContent,
      localeFile.jsonContent,
    );

    if (missing.isEmpty) {
      i18PrintNormal(
        "✅ No missing keys in ${localeFile.localeString}",
        writeLine: true,
      );
      continue;
    }

    i18PrintNormal(
      "_______________________________________________________________________\n"
      "Missing keys in ${localeFile.localeString}",
      writeLine: true,
    );

    i18PrintDebug(missing.toPrettyString());

    final translatedMissing = await I18nTranslationHelper.translateMap(
      map: missing,
      from: config.defaultLocale.locale.languageCode,
      to: localeFile.locale.languageCode,
      charBatchLimit: charBatchLimit,
      autoTranslate: autoTranslate,
    );

    if (translatedMissing?.isEmpty ?? true) {
      continue;
    }

    await I18nTranslationHelper.promptAndApplyTranslation(
      localeFile: localeFile,
      translatedMissing: translatedMissing,
    );
  }

  i18PrintNormal(
    "✅ All translations done!",
    writeLine: true,
  );

  if (autoGenerate) {
    i18PrintNormal(
      "🔄 Running: dart run i18n_json",
      writeLine: true,
    );
    final result = await Process.run(
      'dart',
      ['run', 'i18n_json'],
      runInShell: true,
    );

    if (result.exitCode == 0) {
      i18PrintNormal(
        "✅ i18n_json generation completed.",
        writeLine: true,
      );
      i18PrintDebug(result.stdout);
      await I18nLanguageHelper.postProcessI18nJson(
        config,
      );
      if (autoDartFixGeneratedFile) {
        await I18nLanguageHelper.fixGeneratedFiles(
          config.generatedDirectory.path,
        );
      }
    } else {
      i18PrintError("❌ Failed to generate i18n files:");
      i18PrintError(result.stderr);
      exit(result.exitCode);
    }
  }
}

void processArgs(List<String> args) {
  // Parse command-line arguments
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    switch (arg) {
      case '--batch-limit':
        if (i + 1 < args.length) {
          charBatchLimit = int.tryParse(args[i + 1]) ?? charBatchLimit;
          i++;
        }
        break;
      case '--auto-translate':
        autoTranslate = true;
        break;
      case '--auto_apply-translations':
        autoApplyTranslations = true;
        break;
      case '--show-debug':
        showDebug = true;
        break;
      case '--no-debug':
        showDebug = false;
        break;
      case '--autoGenerate':
        autoGenerate = true;
        break;
      case '--no-autoGenerate':
        autoGenerate = false;
        break;
      case '--addMissingOverrides':
        addMissingOverridesGeneratedFile = true;
        break;
      case '--no-addMissingOverrides':
        addMissingOverridesGeneratedFile = false;
        break;
      case '--key-case':
        if (i + 1 < args.length) {
          keyCase = I18nKeyCase.fromString(args[i + 1]);
          i++;
          i18PrintDebug(
            "Key Case: $keyCase",
          );
        } else {
          i18PrintError(
              "Error: --key-case requires a value (camel, pascal, snake, kebab)");
          exit(1);
        }
        break;
      case '--autoDartFixGeneratedFile':
        autoDartFixGeneratedFile = true;
        break;
      case '--no-autoDartFixGeneratedFile':
        autoDartFixGeneratedFile = false;
        break;
      case '--enhanceGeneratedFile':
        replaceLocaleSetter = true;
        break;
      case '--no-enhanceGeneratedFile':
        replaceLocaleSetter = false;
        break;
      case '--help':
      case '-h':
        print(
          "flutter_i18n_translator CLI usage:\n"
          "--batch-limit <number>         Set max characters per batch (default: $charBatchLimit)\n"
          "--auto-translate               Automatically send translations without confirmation\n"
          "--auto_apply-translations      Apply translations without user prompt\n"
          "--autoGenerate                 Automatically generate missing keys\n"
          "--no-autoGenerate              Disable automatic key generation\n"
          "--addMissingOverrides          Ensure WidgetsLocalizations overrides are added to I18n\n"
          "--no-addMissingOverrides       Disable adding overrides to I18n\n"
          "--show-debug                   Enable debug messages\n"
          "--no-debug                     Disable debug messages\n"
          "--enhanceGeneratedFile           Enhance I18n.dart (replace locale setter, add I18n.current)\n"
          "--no-enhanceGeneratedFile        Keep I18n.dart unmodified (use default generated code)\n"
          "--key-case <style>             Convert all keys to a specific case:\n"
          "                                - camel   (exampleKey)\n"
          "                                - pascal  (ExampleKey)\n"
          "                                - snake   (example_key)\n"
          "                                - kebab   (example-key)\n"
          "--autoDartFixGeneratedFile     Automatically run 'dart fix --apply' on generated files\n"
          "--no-autoDartFixGeneratedFile  Disable automatic 'dart fix' after generation\n"
          "--help, -h                     Show this help message",
        );
        exit(0);
    }
  }
}
