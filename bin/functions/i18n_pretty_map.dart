import 'dart:convert';

extension PrettyMap on Map {
  /// Returns a pretty-printed JSON string of the map
  String toPrettyString({String indent = '  '}) {
    return const JsonEncoder.withIndent('  ').convert(this);
  }
}
