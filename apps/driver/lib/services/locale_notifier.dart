import 'package:flutter/material.dart';

import 'driver_prefs.dart';

/// App-wide locale — persisted in [DriverPrefs], triggers full rebuild on change.
class LocaleNotifier extends ChangeNotifier {
  LocaleNotifier._();

  static final LocaleNotifier instance = LocaleNotifier._();

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode == 'ar';

  Future<void> loadSaved() async {
    final code = await DriverPrefs.instance.getLocaleCode();
    _locale = Locale(code ?? 'en');
    notifyListeners();
  }

  Future<void> setLocale(Locale locale, {bool persist = true}) async {
    if (_locale == locale) return;
    _locale = locale;
    if (persist) {
      await DriverPrefs.instance.saveLocaleCode(locale.languageCode);
    }
    notifyListeners();
  }
}
