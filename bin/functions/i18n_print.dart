part of "../app.dart";

/// Prints error messages in red color
void i18PrintError(String message) {
  const red = '\x1B[31m';
  const reset = '\x1B[0m';
  // Use stderr for errors so they can be redirected separately if needed
  stderr.writeln('$red$message$reset');
}

/// Prints debug messages in green color
void i18PrintDebug(
  String message, {
  bool writeLine = true,
}) {
  if (!showDebug) {
    return;
  }
  const green = '\x1B[32m';
  const reset = '\x1B[0m';
  final string = '$green[DEBUG] $message$reset';
  if (writeLine) {
    stderr.writeln(string);
  } else {
    stderr.write(string);
  }
}

void i18PrintNormal(
  String message, {
  required bool writeLine,
}) {
  if (writeLine) {
    stderr.writeln(message);
  } else {
    stderr.write(message);
  }
}
