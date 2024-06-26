import 'package:bananokeeper/app_router.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/pow/local_work.dart';
import 'package:bananokeeper/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';

class LoadingIndicatorDialog {
  static final LoadingIndicatorDialog _singleton =
      LoadingIndicatorDialog._internal();
  late BuildContext _context;
  bool isDisplayed = false;
  bool showCancelButton = false;
  //TODO: changable by user
  final int cancelTimeoutSeconds = 10;
  factory LoadingIndicatorDialog() {
    return _singleton;
  }

  LoadingIndicatorDialog._internal();

  show(BuildContext context, {String text = '', required BaseTheme theme}) {
    text = (text == ''
        ? AppLocalizations.of(context)!.loadingWidgetDefaultMsg
        : text);
    if (isDisplayed) {
      return;
    }
    showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          _context = context;
          isDisplayed = true;
          showCancelButton = false;
          return StatefulBuilder(builder:
              (BuildContext context, void Function(void Function()) setState) {
            Future.delayed(
                Duration(
                  seconds: cancelTimeoutSeconds,
                ), () {
              showCancelButton = true;
              if (isDisplayed) {
                setState(() {});
              }
            });
            return WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                backgroundColor: theme.primary,
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, top: 16, right: 16),
                          child: Container(
                            height: 20,
                            width: 20,
                            decoration: BoxDecoration(
                              color: theme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: CircularProgressIndicator(
                              color: theme.text,
                              backgroundColor: theme.textDisabled,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            text,
                            style: TextStyle(
                              color: theme.text,
                            ),
                          ),
                        ),
                        if (showCancelButton) ...[
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              style: theme.btnStyleNoBorder,
                              onPressed: () {
                                services<LocalWork>().cancelWork();

                                dismiss(resultStatus: false);

                                // Navigator.pop(context);
                              },
                              child: Text(
                                // appLocalizations!.
                                AppLocalizations.of(context)!.cancel,
                                style: TextStyle(color: theme.text),
                              ),
                            ),
                          ),
                        ],
                        const Gap(5),
                      ],
                    ),
                  )
                ],
              ),
            );
          });
        });
  }

  dismiss({bool resultStatus = true}) {
    if (isDisplayed) {
      isDisplayed = false;
      showCancelButton = false;
      Navigator.of(_context).pop(resultStatus);
    }
  }
}
