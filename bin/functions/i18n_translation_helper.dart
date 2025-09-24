part of "../app.dart";

abstract class I18nTranslationHelper {
  static final translator = GoogleTranslator();

  /// Flattens a nested MapString, dynamic into a flat map of paths -> values
  static Map<String, String> flattenMap(
    Map<String, dynamic> map, [
    String parentKey = '',
  ]) {
    final flatMap = <String, String>{};

    map.forEach((key, value) {
      final path = parentKey.isEmpty ? key : '$parentKey.$key';
      if (value is String) {
        flatMap[path] = value;
      } else if (value is Map<String, dynamic>) {
        flatMap.addAll(flattenMap(value, path));
      }
    });

    return flatMap;
  }

  /// Reconstruct nested map from flat map of paths -> values
  static Map<String, dynamic> unflattenMap(Map<String, String> flatMap) {
    final map = <String, dynamic>{};

    for (var entry in flatMap.entries) {
      final keys = entry.key.split('.');
      Map<String, dynamic> current = map;
      for (int i = 0; i < keys.length; i++) {
        final key = keys[i];
        if (i == keys.length - 1) {
          current[key] = entry.value;
        } else {
          current[key] ??= <String, dynamic>{};
          current = current[key] as Map<String, dynamic>;
        }
      }
    }

    return map;
  }

  /// Translate a nested Map(String, dynamic) using GoogleTranslator in a single batch
  static Future<Map<String, dynamic>?> translateMap({
    required Map<String, dynamic> map,
    required String from,
    required String to,
    int charBatchLimit = 3000,
    bool autoTranslate = false,
  }) async {
    // Flatten the nested map
    final flatMap = flattenMap(map);
    if (flatMap.isEmpty) return {};

    i18PrintDebug(
      "Sending request to translate ${flatMap.length} items to $to",
    );

    // Join all values into a single text with newline separator
    final allText = flatMap.values.toList();

    // Send one request
    final translated = await translateWithRateLimit(
      allText,
      from: from,
      to: to,
    );
    if (translated?.isEmpty ?? true) {
      i18PrintError("⚠️ Translations are Empty");
      return null;
    } else if (translated!.length != flatMap.length) {
      i18PrintError(
        "⚠️ Translation count mismatch: expected ${flatMap.length},"
        " got ${translated.length}\n"
        "${translated.join('\n')}",
      );
      return null;
    }

    // Map back translations to keys
    final translations = <String, String>{};
    int index = 0;
    for (final key in flatMap.keys) {
      translations[key] = translated[index]; // get translation for this key
      index++;
    }

    // Unflatten back to nested map
    return unflattenMap(translations);
  }

  /// Translates a list of texts in batches according to a character limit per request.
  /// Lines are never split; if a line exceeds [charBatchLimit], it's sent as a single batch.
  /// Translates a list of texts in batches according to a character limit per request.
  /// Lines are never split; if a line exceeds [charBatchLimit], it's sent as a single batch.
  /// Translates a list of texts in batches according to a character limit per request.
  /// Lines are never split; if a line exceeds [charBatchLimit], it's sent as a single batch.
  static Future<List<String>?> translateWithRateLimit(
    List<String> lines, {
    required String from,
    required String to,
  }) async {
    try {
      /// Step 1: Split lines into batches
      final batches = <String>[];
      int start = 0;
      while (start < lines.length) {
        int end = start;
        int currentLen = 0;

        // Build a batch of lines without exceeding charLimit
        while (end < lines.length) {
          final lineLen = lines[end].length + 1; // +1 for newline
          if (currentLen + lineLen > charBatchLimit) {
            // If a single line exceeds the limit, send it alone
            if (currentLen == 0) end++;
            break;
          }
          currentLen += lineLen;
          end++;
        }

        final batchText = lines.sublist(start, end).join('\n');
        batches.add(batchText);

        start = end;
      }

      /// Step 2: Show batches for confirmation
      i18PrintNormal(
        "_______________________________________________________________________\n"
        "⚠️ The text will be sent in ${batches.length} batches:",
        writeLine: true,
      );
      for (int i = 0; i < batches.length; i++) {
        i18PrintNormal("Batch ${i + 1}:\n${batches[i]}\n---", writeLine: true);
      }

      // Ask for user confirmation
      if (!autoTranslate) {
        i18PrintNormal(
          "Send these batches for translation? (Y/N): ",
          writeLine: false,
        );
        final input = stdin.readLineSync()?.toUpperCase() ?? 'N';
        if (input != 'Y' && input != 'YES') {
          i18PrintNormal(
            "Translation cancelled by user.",
            writeLine: true,
          );
          return null;
        }
      }

      /// Step 3: Send all batches in a loop with **casing-safe placeholder protection**
      final translatedLines = <String>[];
      for (final batch in batches) {
        try {
          // Step 3a: Extract placeholders and replace with casing-safe tokens
          final placeholderMap = <String, String>{};
          int counter = 0;
          final escapedBatch =
              batch.replaceAllMapped(RegExp(r'\{[^}]+\}'), (match) {
            final token = '__PH${counter}__'; // safe, no spaces, single word
            placeholderMap[token] = match.group(0)!;
            counter++;
            return token;
          });
          String restorePlaceholdersCaseInsensitive(
              String text, Map<String, String> placeholderMap) {
            placeholderMap.forEach((token, original) {
              // Replace all occurrences ignoring case
              text = text.replaceAll(
                  RegExp(RegExp.escape(token), caseSensitive: false), original);
            });
            return text;
          }

          // Step 3b: Translate the escaped batch
          final translated = await translator.translate(
            escapedBatch,
            from: from,
            to: to,
          );

          // Step 3c: Restore placeholders exactly
          String restored = restorePlaceholdersCaseInsensitive(
              translated.text, placeholderMap);
          placeholderMap.forEach((token, original) {
            restored = restored.replaceAll(token, original);
          });

          // Step 3d: Split translated batch back into lines
          translatedLines.addAll(restored.split('\n'));
        } catch (e) {
          i18PrintError(
            "An Error Happened While Translating $to/Batch ${batches.indexOf(batch) + 1} ($e): $batch",
          );
        }
      }

      return translatedLines;
    } catch (e) {
      i18PrintError("An Error Happened While Translating $to ($e)");
      return null;
    }
  }

  static Future<void> promptAndApplyTranslation({
    required I18nLocaleFile localeFile,
    required Map<String, dynamic>? translatedMissing,
  }) async {
    if (translatedMissing?.isEmpty ?? true) return;

    if (autoApplyTranslations) {
      localeFile.addOrReplaceEntries(translatedMissing!);
      localeFile.save();
      i18PrintNormal(
        "✅ Applied translations for ${localeFile.localeString}",
        writeLine: true,
      );
    } else {
      i18PrintNormal(
        "------------------------------------------------------------------------"
        "\nTranslated Missing keys in ${localeFile.localeString}:\n ${translatedMissing!.toPrettyString()}",
        writeLine: true,
      );
      i18PrintNormal(
        "Do you want to apply these translations? (Y = yes / N = stop / S = skip): ",
        writeLine: false,
      );

      final input = stdin.readLineSync()?.trim().toUpperCase();

      if (input == 'Y' || input == 'YES') {
        // Apply and save
        localeFile.addOrReplaceEntries(translatedMissing);
        localeFile.save();
        i18PrintNormal(
          "✅ Applied translations for ${localeFile.localeString}",
          writeLine: true,
        );
      } else if (input == 'N' || input == 'NO') {
        // Stop the whole process
        i18PrintNormal(
          "❌ Stopping process as requested by user.",
          writeLine: true,
        );
        exit(0);
      } else if (input == 'S' || input == 'SKIP') {
        // Skip this locale
        i18PrintNormal(
          "➡️ Skipped ${localeFile.localeString}",
          writeLine: true,
        );
      } else {
        // Invalid input, ask again
        i18PrintNormal(
          "⚠️ Invalid input, please enter Y, N or S.",
          writeLine: true,
        );
        await promptAndApplyTranslation(
          localeFile: localeFile,
          translatedMissing: translatedMissing,
        );
      }
    }
  }
}
