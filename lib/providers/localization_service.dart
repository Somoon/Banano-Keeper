import 'package:flutter/material.dart';

class LocalizationModel extends ChangeNotifier {
  Locale selectedLocale = const Locale("en");
  String language = 'English';

  List<Map<String, String>> availableLanguages = [
    {
      "language": "Arabic",
      "displayedLanguage": "العريية",
    },
    {
      "language": "English",
      "displayedLanguage": "English",
    },
  ];
  void setLocale(lang) {
    switch (lang) {
      case "Spanish":
        selectedLocale = const Locale("es");
        language = lang;

      case "Arabic":
        selectedLocale = const Locale("ar");
        language = lang;

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

  Map<String, String> getLanguage() {
    return availableLanguages
        .firstWhere((element) => element['language']! == language);
  }

  Iterable<Locale> supportedLocales = const [
    Locale('en'), // English
    Locale('es'), // Spanish
    Locale('ar'), // Arabic
  ];
}
