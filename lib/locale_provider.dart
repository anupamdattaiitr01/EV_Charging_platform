import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  // Default language is English
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadSavedLocale();
  }

  // Function to change the language
  void setLocale(Locale locale) async {
    if (!['en', 'hi'].contains(locale.languageCode)) return;

    _locale = locale;
    notifyListeners(); // This tells the whole app to rebuild instantly

    // Save the choice to the phone's storage
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
  }

  // Function to load the saved language when the app starts
  void _loadSavedLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedLanguage = prefs.getString('language_code');
    if (savedLanguage != null) {
      _locale = Locale(savedLanguage);
      notifyListeners();
    }
  }
}