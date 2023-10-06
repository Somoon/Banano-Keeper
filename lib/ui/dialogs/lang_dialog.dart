import 'package:bananokeeper/app_router.dart';
import 'package:flutter/material.dart';

import 'package:bananokeeper/providers/localization_service.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/shared_prefs_service.dart';
import 'package:bananokeeper/themes.dart';
import 'package:gap/gap.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LangDialog extends StatefulWidget with GetItStatefulWidgetMixin {
  LangDialog({super.key});

  @override
  LangDialogState createState() => LangDialogState();
}

class LangDialogState extends State<LangDialog> with GetItStateMixin {
  @override
  Widget build(BuildContext context) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    List<Map<String, String>> availableLanguages =
        get<LocalizationModel>().availableLanguages;

    List<Widget> langWidgets = [];
    for (Map<String, String> aLang in availableLanguages) {
      langWidgets.add(createLangButton(aLang, AppLocalizations.of(context)));
    }
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
              children: langWidgets,
              // createLangButton("Arabic", AppLocalizations.of(context)),
              // createLangButton("English", AppLocalizations.of(context)),
              // createLangButton("Spanish"),
            ),
            const Gap(15),
            const Divider(
              thickness: 1,
            ),
            TextButton(
              style: currentTheme.btnStyleNoBorder,
              onPressed: () {
                services<AppRouter>().pop();
              },
              child: Text(
                AppLocalizations.of(context)!.close,
                style: TextStyle(color: currentTheme.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget createLangButton(Map<String, String> label, appLocalizations) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    var currentLanguage = watchOnly((LocalizationModel x) => x.getLanguage());
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        style: currentTheme.btnStyleNoBorder,
        onPressed: () {
          _setlang(label['language']!);
          setState(() {});
          // Navigator.pop(context);
        },
        child: Text(
          // appLocalizations!.
          label['displayedLanguage']!,
          style: TextStyle(
              color: (currentLanguage['language'] != label['language']!
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
