import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DynamicTranslationProvider extends ChangeNotifier {
  final GoogleTranslator _translator = GoogleTranslator();
  String _targetLanguage = 'en';

  // Caches translations in memory to prevent spamming the API
  final Map<String, String> _translationCache = {};
  final Set<String> _isFetching = {};

  String get currentLanguage => _targetLanguage;

  DynamicTranslationProvider() {
    _loadSavedLanguage();
  }

  /// Called directly from the UI. Returns the cached translation instantly.
  /// If not cached, it returns English temporarily and fetches the translation in the background.
  String translate(String englishText) {
    // Return instantly if the target language is English
    if (_targetLanguage == 'en') return englishText;

    final cacheKey = '${_targetLanguage}_$englishText';

    // Return cached translation if it already exists
    if (_translationCache.containsKey(cacheKey)) {
      return _translationCache[cacheKey]!;
    }

    // Fetch from Google Translate API only if not already fetching
    if (!_isFetching.contains(cacheKey)) {
      _isFetching.add(cacheKey);
      _fetchTranslation(englishText, cacheKey);
    }

    return englishText; // Fallback while loading
  }

  Future<void> _fetchTranslation(String text, String cacheKey) async {
    try {
      final translation = await _translator.translate(text, from: 'en', to: _targetLanguage);
      _translationCache[cacheKey] = translation.text;
      _isFetching.remove(cacheKey);

      // Force the UI to rebuild with the new translated text
      notifyListeners();
    } catch (e) {
      debugPrint("Translation failed: $e");
      _isFetching.remove(cacheKey);
    }
  }

  // Call this from your UI when the user taps "Switch Language"
  void setLanguage(String languageCode) async {
    _targetLanguage = languageCode;
    notifyListeners();

    // Save to device storage
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', languageCode);
  }

  void _loadSavedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _targetLanguage = prefs.getString('languageCode') ?? 'en';
    notifyListeners();
  }
}