import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LanguageProvider() {
    loadLanguage();
  }

  Future<void> changeLanguage(String code) async {
    _locale = Locale(code);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("languageCode", code);

    notifyListeners();
  }

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    String code = prefs.getString("languageCode") ?? "en";

    _locale = Locale(code);

    notifyListeners();
  }
}