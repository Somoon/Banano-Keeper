import 'package:flutter/material.dart';
import 'package:bananokeeper/app_router.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/shared_prefs_service.dart';
import 'package:bananokeeper/themes.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ThemesDialog extends StatefulWidget with GetItStatefulWidgetMixin {
  ThemesDialog({super.key});

  @override
  ThemesDialogState createState() => ThemesDialogState();
}

class ThemesDialogState extends State<ThemesDialog> with GetItStateMixin {
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
                createThemeButton("Yellow"),
                createThemeButton("Dark"),
                // createThemeButton("Second"),
                createThemeButton("Slate"),
              ],
            ),
            const SizedBox(height: 15),
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

  Widget createThemeButton(label) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        style: currentTheme.btnStyleNoBorder,
        onPressed: (services<ThemeModel>().activeTheme == label)
            ? null
            : () {
                _setTheme(label);
                setState(() {});
                // Navigator.pop(context);
              },
        child: Text(
          label,
          style: TextStyle(
              color: (getTextColor(label)
                  ? currentTheme.text
                  : currentTheme.textDisabled)),
        ),
      ),
    );
  }

  getTextColor(themeName) {
    var activeTheme = watchOnly((ThemeModel x) => x.activeTheme);
    if (activeTheme == themeName) return false;
    return true;
  }

  void _setTheme(String themeName) {
    setState(() {
      services<ThemeModel>().setTheme(themeName);
      services<SharedPrefsModel>().saveTheme(themeName);
    });
  }
}
