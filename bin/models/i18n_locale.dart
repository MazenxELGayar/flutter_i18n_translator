part of '../app.dart';

class I18nLocale {
  final String languageCode;
  final String? countryCode;

  I18nLocale(this.languageCode, [this.countryCode]);

  @override
  String toString() => countryCode != null ? '$languageCode-$countryCode' : languageCode;

  @override
  bool operator ==(Object other) =>
      other is I18nLocale &&
          other.languageCode == languageCode &&
          other.countryCode == countryCode;

  @override
  int get hashCode => languageCode.hashCode ^ (countryCode?.hashCode ?? 0);
}
