import 'dart:convert';
import 'dart:io';
import 'package:translator/translator.dart';

import 'functions/i18n_pretty_map.dart';

part 'models/i18n_locale.dart';

part 'models/text_direction.dart';

part "functions/i18n_languages_helper.dart";

part "functions/i18n_translation_helper.dart";

part "functions/i18n_print.dart";

part "models/i18n_config.dart";

part "models/i18n_locale_file.dart";

// Default CLI options
int charBatchLimit = 3000;
bool autoTranslate = false;
bool autoApplyTranslations = false;
bool showDebug = false;

void runTranslator(List<String> args) async {
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
      case '--help':
      case '-h':
        print(
          "flutter_i18n_translator CLI usage:\n"
          "--batch-limit <number>         Set max characters per batch (default: $charBatchLimit)\n"
          "--auto-translate               Automatically send translations without confirmation\n"
          "--auto_apply-translations      Apply translations without user prompt\n"
          "--show-debug                   Enable debug messages\n"
          "--no-debug                     Disable debug messages\n"
          "--help, -h                     Show this help message",
        );
        exit(0); // Exit immediately after showing help
    }
  }

  i18PrintDebug("Loading I18n Configurations...");
  final I18nConfig? config = await I18nLanguageHelper.loadI18nConfig();
  if (config == null) {
    i18PrintError('❌ Failed to load i18n configuration.');
    exit(1);
  } else {
    i18PrintDebug("I18n Configurations was parsed Successfully!");
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
}
