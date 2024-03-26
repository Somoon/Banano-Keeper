import 'package:auto_size_text/auto_size_text.dart';
import 'package:bananokeeper/app_router.dart';
import 'package:bananokeeper/providers/shared_prefs_service.dart';
import 'package:bananokeeper/providers/user_data.dart';
import 'package:flutter/material.dart';

import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/themes.dart';
import 'package:gap/gap.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ReceiveDialog extends StatefulWidget with GetItStatefulWidgetMixin {
  ReceiveDialog({super.key});

  @override
  ReceiveDialogState createState() => ReceiveDialogState();
}

class ReceiveDialogState extends State<ReceiveDialog> with GetItStateMixin {
  final amountController = TextEditingController();
  FocusNode amountControllerFocusNode = FocusNode();
  double amount = 0.0;
  @override
  void initState() {
    super.initState();
    amountControllerFocusNode.addListener(() {
      if (amountControllerFocusNode.hasFocus) {
        print(amountController.text);
        try {
          double? valueInt = double.tryParse(amountController.text);

          if (valueInt != null) {
            if (valueInt >= 0) {
              print('OK amount $valueInt');
              amount = valueInt;
            }
          }
        } catch (_) {}
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    bool autoReceive = watchOnly((UserData x) => x.getAutoReceive());
    double minToReceive = watchOnly((UserData x) => x.getMinToReceive());
    bool validAmount = false;
    amountController.text = minToReceive.toString();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 100,
          maxWidth: 500,
          maxHeight: 600,
        ),
        decoration: BoxDecoration(
            color: currentTheme.primary,
            borderRadius: BorderRadius.circular(25)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                children: [
                  createAuthOnStartUp(currentTheme, autoReceive),
                  if (autoReceive) ...[
                    Text(
                      "Minimum to receive:",
                      style: TextStyle(
                        color: currentTheme.text,
                        fontSize: 16,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 100, right: 100),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        focusNode: amountControllerFocusNode,
                        controller: amountController,
                        autofocus: false,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          filled: true,
                          fillColor: currentTheme.secondary,
                          isDense: false,
                          isCollapsed: true,
                          contentPadding: const EdgeInsets.all(
                            // left: 8,
                            // right: 8,
                            8,
                          ),
                          hintText:
                              AppLocalizations.of(context)!.enterAmountHint,
                          hintStyle:
                              TextStyle(color: currentTheme.textDisabled),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        autovalidateMode: AutovalidateMode.always,
                        validator: (value) {
                          if (value != null) {
                            double? valueInt = double.tryParse(value);

                            try {
                              if (valueInt != null) {
                                if (valueInt >= 0.0) {
                                  amount = valueInt;
                                  amountController.text = amount.toString();
                                  setState(() {});
                                  return null;
                                } else {
                                  // return AppLocalizations.of(context)!
                                  //     .cantNegative;
                                }
                              }
                            } catch (_) {}
                          }
                          return null;
                        },
                        style: TextStyle(color: currentTheme.text),
                      ),
                    ),
                  ],
                ],
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
      ),
    );
  }

  Padding createAuthOnStartUp(BaseTheme currentTheme, bool autoReceive) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AutoSizeText(
            "Auto receive: ",
            style: TextStyle(
              color: currentTheme.text,
              fontSize: 16,
            ),
          ),
          Switch(
            // This bool value toggles the switch.
            value: autoReceive,
            activeColor: currentTheme.text,
            activeTrackColor: Colors.black38,
            inactiveThumbColor: currentTheme.textDisabled,

            onChanged: (bool value) {
              changeAR(value);
            },
          ),
        ],
      ),
    );
  }

  changeAR(bool value) {
    setState(() {
      services<UserData>().setAutoReceive(value);
    });
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
