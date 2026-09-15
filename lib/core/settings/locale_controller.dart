import 'package:flutter/widgets.dart';

class LocaleController extends ChangeNotifier {
  LocaleController([Locale? initial]) : _locale = initial;

  Locale? _locale;

  Locale? get locale => _locale;

  void setLocale(Locale? value) {
    if (_locale == value) return;
    _locale = value;
    notifyListeners();
  }
}
