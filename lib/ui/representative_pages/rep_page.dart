import 'package:bananokeeper/api/representative_json.dart';
import 'package:bananokeeper/ui/representative_pages/list_rep_change.dart';
import 'package:bananokeeper/ui/representative_pages/manual_rep_change.dart';
import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bananokeeper/providers/account.dart';
import 'package:bananokeeper/utils/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';

class RepPage {
  static final RepPage _singleton = RepPage._internal();
  late BuildContext _context;
  bool isDisplayed = false;

  factory RepPage() {
    return _singleton;
  }

  RepPage._internal();

  Future<bool?> show(
      BuildContext context,
      currentTheme,
      String repName,
      String score,
      String activeRep,
      List<Representative>? repList,
      Account account,
      Representative? rep) async {
    if (isDisplayed) {
      return false;
    }
    double height = MediaQuery.of(context).size.height;
    String weight =
        "Voting weight: ${rep?.weightPercentage.toStringAsFixed(2)}%";
    return showModalBottomSheet<bool>(
        enableDrag: true,
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        backgroundColor: currentTheme.primary,
        builder: (BuildContext context) {
          bool additionalInfo = false;

          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              // services<QueueService>().add(account.getOverview(true));
              return GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: currentTheme.primary,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    color: currentTheme.primary,
                  ),
                  child: SizedBox(
                    height: height / 1.25,
                    child: Center(
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            height: 5,
                            width: MediaQuery.of(context).size.width * 0.15,
                            decoration: BoxDecoration(
                              color: currentTheme.secondary,
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: 10,
                                ),
                                child: SizedBox(
                                  child: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        // addressController.clear();
                                        Navigator.of(context).pop(false);
                                      });
                                    },
                                    style: ButtonStyle(
                                      foregroundColor:
                                          MaterialStatePropertyAll<Color>(
                                              currentTheme.textDisabled),
                                      // backgroundColor:
                                      //     MaterialStatePropertyAll<
                                      //         Color>(primary),
                                    ),
                                    child: const Icon(Icons.close),
                                  ),
                                ),
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            child: Column(
                              children: [
                                AutoSizeText(
                                  AppLocalizations.of(context)!.representative,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: currentTheme.text,
                                  ),
                                ),
                                const Gap(50),
                                AutoSizeText(
                                  "Current Representative:",
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: currentTheme.text,
                                    fontSize: 16,
                                  ),
                                ),
                                const Gap(15),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 35.0,
                                    right: 35.0,
                                  ),
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minHeight: 100,
                                    ),
                                    decoration: BoxDecoration(
                                      color: currentTheme.secondary,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          10.0, 15.0, 10.0, 15.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          if (repName != "") ...[
                                            // Row(
                                            //   mainAxisAlignment:
                                            //       MainAxisAlignment.spaceBetween,
                                            //   children: [
                                            //     AutoSizeText(
                                            //       repName,
                                            //       maxLines: 1,
                                            //       style: TextStyle(
                                            //         color: currentTheme.text,
                                            //         fontSize: 16,
                                            //       ),
                                            //     ),
                                            //     AutoSizeText(
                                            //       score,
                                            //       maxLines: 1,
                                            //       style: TextStyle(
                                            //         color: currentTheme.text,
                                            //         fontSize: 12,
                                            //       ),
                                            //     ),
                                            //   ],
                                            // ),
                                            Center(
                                              child: AutoSizeText(
                                                repName,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  color: currentTheme.text,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            const Gap(10),
                                          ],

                                          // AutoSizeText(
                                          //   account.getRep(),
                                          //   maxLines: 2,
                                          //   style: TextStyle(
                                          //     fontSize: 14,
                                          //     color: currentTheme.text,
                                          //     fontFamily: 'monospace',
                                          //   ),
                                          // ),
                                          Utils().colorffix(
                                              activeRep, currentTheme),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const Gap(40),
                                if (rep != null) ...[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 40,
                                      right: 40,
                                    ),
                                    child: Theme(
                                      data: Theme.of(context).copyWith(
                                        primaryColor: currentTheme.offColor,
                                        unselectedWidgetColor:
                                            currentTheme.offColor,
                                        dividerColor: Colors.transparent,
                                      ),
                                      child: ExpansionTile(
                                        onExpansionChanged: (bool value) {
                                          setState(() {
                                            additionalInfo = !additionalInfo;
                                          });
                                        },
                                        title: const Text("More info: "),
                                        collapsedTextColor: currentTheme.text,
                                        collapsedBackgroundColor:
                                            Colors.transparent,
                                        textColor: currentTheme.text,
                                        collapsedIconColor:
                                            currentTheme.offColor,
                                        iconColor: currentTheme.offColor,
                                        children: <Widget>[
                                          Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 5.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    left: 20,
                                                    right: 20,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        weight,
                                                        style: TextStyle(
                                                          color: currentTheme
                                                              .offColor,
                                                        ),
                                                      ),
                                                      Text(
                                                        score,
                                                        style: TextStyle(
                                                          color: currentTheme
                                                              .offColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // Gap(10),
                                                // Padding(
                                                //   padding:
                                                //       const EdgeInsets.only(
                                                //     left: 20,
                                                //     right: 20,
                                                //   ),
                                                //   child: Row(
                                                //     mainAxisAlignment:
                                                //         MainAxisAlignment
                                                //             .spaceBetween,
                                                //     children: [
                                                //       Text("Uptime:"),
                                                //     ],
                                                //   ),
                                                // )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                                Gap(!additionalInfo ? 15 : 0),
                                Padding(
                                    padding: const EdgeInsets.all(40.0),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          width: double.infinity,
                                          height: 48,
                                          child: OutlinedButton(
                                            style: ButtonStyle(
                                              overlayColor: MaterialStateColor
                                                  .resolveWith((states) =>
                                                      currentTheme.text
                                                          .withOpacity(0.3)),
                                              // backgroundColor: MaterialStatePropertyAll<Color>(Colors.green),
                                              shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                              ),

                                              side: MaterialStatePropertyAll<
                                                  BorderSide>(
                                                BorderSide(
                                                  color: currentTheme
                                                      .buttonOutline,
                                                  width: 1,
                                                ),
                                              ),
                                            ),
                                            onPressed: () async {
                                              var appLocalizations =
                                                  AppLocalizations.of(context);
                                              bool? result =
                                                  await ListRepChange().show(
                                                      context,
                                                      currentTheme,
                                                      appLocalizations,
                                                      repList,
                                                      account);

                                              setState(() {
                                                if (result != null && result) {
                                                  Navigator.of(context)
                                                      .pop(true);
                                                }
                                              });
                                            },
                                            child: Text(
                                              "Choose from list",
                                              // AppLocalizations.of(context)!.add,
                                              style: TextStyle(
                                                color: currentTheme.text,
                                                fontSize: currentTheme.fontSize,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const Gap(30),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 48,
                                          child: OutlinedButton(
                                            style: ButtonStyle(
                                              overlayColor: MaterialStateColor
                                                  .resolveWith((states) =>
                                                      currentTheme.text
                                                          .withOpacity(0.3)),
                                              // backgroundColor: MaterialStatePropertyAll<Color>(Colors.green),
                                              shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                              ),

                                              side: MaterialStatePropertyAll<
                                                  BorderSide>(
                                                BorderSide(
                                                  color: currentTheme
                                                      .buttonOutline,
                                                  width: 1,
                                                ),
                                              ),
                                            ),
                                            onPressed: () async {
                                              bool? result =
                                                  await ManualRepChange().show(
                                                      context,
                                                      currentTheme,
                                                      height,
                                                      AppLocalizations.of(
                                                          context),
                                                      account);
                                              setState(() {
                                                if (result != null && result) {
                                                  Navigator.of(context)
                                                      .pop(true);
                                                }
                                              });
                                            },
                                            child: Text(
                                              "Enter manually",
                                              // AppLocalizations.of(context)!.add,
                                              style: TextStyle(
                                                color: currentTheme.text,
                                                fontSize: currentTheme.fontSize,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        });
  }

  dismiss() {
    if (isDisplayed) {
      Navigator.of(_context).pop();
      isDisplayed = false;
    }
  }
}
