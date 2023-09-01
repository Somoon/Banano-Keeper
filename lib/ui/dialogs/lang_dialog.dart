import 'package:bananokeeper/providers/localization_service.dart';
import 'package:flutter/material.dart';

import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/shared_prefs_service.dart';
import 'package:bananokeeper/themes.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

class LangDialog extends StatefulWidget with GetItStatefulWidgetMixin {
  LangDialog({super.key});

  @override
  LangDialogState createState() => LangDialogState();
}

class LangDialogState extends State<LangDialog> with GetItStateMixin {
  @override
  Widget build(BuildContext context) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);

    return Container(
      constraints: const BoxConstraints(
        minWidth: 100,
        maxWidth: 500,
        maxHeight: 600,
      ),
      decoration: BoxDecoration(
          color: currentTheme.primary, borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              children: [
                createLangButton("Arabic"),
                createLangButton("English"),
                // createLangButton("Spanish"),
              ],
            ),
            const SizedBox(height: 15),
            const Divider(
              thickness: 1,
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Close',
                style: TextStyle(color: currentTheme.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget createLangButton(label) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    var currentLanguage = watchOnly((LocalizationModel x) => x.getLanguage());

    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          _setlang(label);
          setState(() {});
          // Navigator.pop(context);
        },
        child: Text(
          label,
          style: TextStyle(
              color: (currentLanguage != label
                  ? currentTheme.text
                  : currentTheme.textDisabled)),
        ),
      ),
    );
  }

  void _setlang(String lang) {
    setState(() {
      services<LocalizationModel>().setLocale(lang);
      services<SharedPrefsModel>().saveLang(lang);
    });
  }
}
