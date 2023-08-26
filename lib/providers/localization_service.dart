import 'package:flutter/material.dart';

class LocalizationModel extends ChangeNotifier {
  Locale selectedLocale = const Locale("en");
  String language = 'English';
  void setLocale(lang) {
    switch (lang) {
      case "Spanish":
        selectedLocale = const Locale("es");
        language = lang;

      case "Arabic":
        selectedLocale = const Locale("ar");
        language = "العريية";

      case "English":
      default:
        selectedLocale = const Locale("en");
        language = "English";
    }
    notifyListeners();
  }

  Locale getLocale() {
    return selectedLocale;
  }

  String getLanguage() {
    return language;
  }

  Iterable<Locale> supportedLocales = const [
    Locale('en'), // English
    Locale('es'), // Spanish
    Locale('ar'), // Arabic
  ];
}
