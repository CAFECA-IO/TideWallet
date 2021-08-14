import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class I18n {
  I18n(Locale locale) {
    _locale = locale;
  }

  static late Locale _locale;
  static late Map<dynamic, dynamic> _localizedValues;

  static I18n of(BuildContext context) {
    return Localizations.of<I18n>(context, I18n)!;
  }

  static String t(String key, {Map<String, String>? values}) {
    String? transaltion = _localizedValues[key];

    if (transaltion == null) return '** $key not found';
    if (values != null && values.isNotEmpty) {
      values.entries.forEach((v) {
        transaltion = transaltion!.replaceAll('{{${v.key}}}', v.value);
      });
    }
    return transaltion!;
  }

  static Locale getLocale() => _locale;

  static Future<I18n> load(Locale locale) async {
    I18n translations = new I18n(locale);

    // update like:
    // assets:
    //    - locale/en.json
    //    - locale/ja.json
    String jsonContent =
        await rootBundle.loadString("locale/${locale.languageCode}.json");
    _localizedValues = json.decode(jsonContent);
    _locale = locale;
    return translations;
  }

  // get currentLanguage => _locale.languageCode;
}

class I18nDelegate extends LocalizationsDelegate<I18n> {
  const I18nDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ja'].contains(locale.languageCode);

  @override
  Future<I18n> load(Locale locale) => I18n.load(locale);

  @override
  bool shouldReload(I18nDelegate old) => false;
}

class SpecificI18nDelegate extends LocalizationsDelegate<I18n> {
  final Locale? overriddenLocale;

  const SpecificI18nDelegate(this.overriddenLocale);

  @override
  bool isSupported(Locale locale) => overriddenLocale != null;

  @override
  Future<I18n> load(Locale locale) => I18n.load(overriddenLocale!);

  @override
  bool shouldReload(LocalizationsDelegate<I18n> old) => true;
}
