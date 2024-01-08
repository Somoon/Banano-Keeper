import 'package:bananokeeper/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InfoDialog {
  static final InfoDialog _singleton = InfoDialog._internal();

  factory InfoDialog() {
    return _singleton;
  }

  InfoDialog._internal();

  show(
      BuildContext context, String title, String info, BaseTheme currentTheme) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return WillPopScope(
          // onWillPop: () async => false,
          onWillPop: () async => true,
          child: AlertDialog(
            backgroundColor: currentTheme.secondary,
            elevation: 2,
            title: Center(child: Text(title)),
            titleTextStyle: currentTheme.textStyle,
            content: Text(info),
            contentTextStyle: TextStyle(
              color: currentTheme.textDisabled,
              fontSize: currentTheme.fontSize - 3,
            ),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    AppLocalizations.of(context)!.close,
                    style: currentTheme.textStyle,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
