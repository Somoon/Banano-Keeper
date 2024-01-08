import 'package:bananokeeper/api/currency_conversion.dart';
import 'package:bananokeeper/app_router.dart';
import 'package:bananokeeper/providers/user_data.dart';
import 'package:flutter/material.dart';

import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/themes.dart';
import 'package:gap/gap.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CurrencyDialog extends StatefulWidget with GetItStatefulWidgetMixin {
  CurrencyDialog({super.key});

  @override
  CurrencyDialogState createState() => CurrencyDialogState();
}

class CurrencyDialogState extends State<CurrencyDialog> with GetItStateMixin {
  @override
  Widget build(BuildContext context) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    List<String> currencies = get<CurrencyConversion>().price.keys.toList();

    List<Widget> currgWidgets = [];
    for (String item in currencies) {
      currgWidgets.add(createCurrencyButton(item));
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
              children: currgWidgets,
            ),
            const Gap(15),
            const Divider(
              thickness: 1,
            ),
            TextButton(
              style: currentTheme.btnStyleNoBorder,
              onPressed: () {
                Navigator.of(context).pop();
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

  Widget createCurrencyButton(String label) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    var currentCurrency = watchOnly((UserData x) => x.getCurrency());
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        style: currentTheme.btnStyleNoBorder,
        onPressed: (services<UserData>().getCurrency() == label)
            ? null
            : () {
                _setCurrency(label);
                setState(() {});
                // Navigator.pop(context);
              },
        child: Text(
          label,
          style: TextStyle(
              color: (currentCurrency != label
                  ? currentTheme.text
                  : currentTheme.textDisabled)),
        ),
      ),
    );
  }

  void _setCurrency(String currency) {
    setState(() {
      services<UserData>().setCurrency(currency);
      // services<SharedPrefsModel>().saveLang(lang); //move to setCurrency
    });
  }
}
