// import 'dart:async';

import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bananokeeper/api/representative_json.dart';
import 'package:bananokeeper/db/dbManager.dart';
import 'package:bananokeeper/initial_pages/initial_page_one.dart';
import 'package:bananokeeper/providers/account.dart';
import 'package:bananokeeper/providers/auth_biometric.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/pow_source.dart';
import 'package:bananokeeper/providers/shared_prefs_service.dart';
import 'package:bananokeeper/providers/user_data.dart';
import 'package:bananokeeper/providers/wallet_service.dart';
import 'package:bananokeeper/providers/wallets_service.dart';
import 'package:bananokeeper/ui/bottom_bar.dart';
import 'package:bananokeeper/ui/changeRepBottomSheet.dart';
import 'package:bananokeeper/ui/dialogs/pow_dialog.dart';
import 'package:bananokeeper/ui/dialogs/security_dialog.dart';
import 'package:bananokeeper/ui/dialogs/themes_dialog.dart';
import 'package:bananokeeper/ui/management/management_address_page.dart';
import 'package:bananokeeper/ui/management/management_page.dart';
import 'package:bananokeeper/ui/management/management_wallet_page.dart';
import 'package:bananokeeper/ui/pin/verify_pin.dart';
import 'package:bananokeeper/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../providers/localization_service.dart';
import '../themes.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

import 'dialogs/lang_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';

class sideDrawer extends StatefulWidget with GetItStatefulWidgetMixin {
  sideDrawer({super.key});

  _sideDrawer createState() => _sideDrawer();
}

class _sideDrawer extends State<sideDrawer>
    with WidgetsBindingObserver, GetItStateMixin {
  @override
  Widget build(BuildContext context) {
    var activeTheme = watchOnly((ThemeModel x) => x.activeTheme);
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    var activeLanguage = watchOnly((LocalizationModel x) => x.getLanguage());

    //Wallet and address

    int walletIndex = watchOnly((WalletsService x) => x.activeWallet);

    String orgWalletName =
        watchOnly((WalletsService x) => x.walletsList[walletIndex]);
    String activeWalletName = watchOnly((WalletService x) => x.getWalletName(),
        instanceName: orgWalletName);

    WalletService wallet = services<WalletService>(instanceName: orgWalletName);
    String currentAccount = watchX((WalletService x) => x.currentAccount,
        instanceName: orgWalletName);

    int accountIndex = wallet.activeIndex;

    String accOrgName = wallet.accountsList[accountIndex];

    var account = services<Account>(instanceName: accOrgName);
    String representative =
        watchOnly((Account x) => x.getRep(), instanceName: accOrgName);

    // var account = watchOnly((WalletsService x) => x.wallets[x.activeWallet]
    //     .accounts[x.wallets[x.activeWallet].getActiveIndex()]);
    var statusBarHeight = MediaQuery.of(context).viewPadding.top;

    String selectedPoWName = watchOnly((PoWSource x) => x.getAPIName());
    //side drawer
    return Drawer(
      backgroundColor: currentTheme.sideDrawerColor,
      child: Container(
        // color: activeTheme.sideDrawerColor,
        // decoration: BoxDecoration(
        //   color: Colors.black,
        // ),
        child: SafeArea(
          minimum: EdgeInsets.only(
            top: (statusBarHeight == 0.0 ? 50 : statusBarHeight),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: <Widget>[
                //Wallet management button
                createPrimaryDrawerButton(
                  AppLocalizations.of(context)!.manageWallets,
                  activeWalletName,
                  ManagementPage(
                    WalletManagementPage(),
                    AppLocalizations.of(context)!.manageWallets,
                  ),
                ),
                //Account management button

                createPrimaryDrawerButton(
                  AppLocalizations.of(context)!.manageAccounts,
                  // Utils().shortenAccount(currentAccount),
                  account.name,
                  ManagementPage(
                    AccountManagementPage(),
                    AppLocalizations.of(context)!.manageAccounts,
                  ),
                ),

                /// TBA NFTs
                ///
                // Text(
                //   "NFTs",
                //   style: TextStyle(
                //     color: currentTheme.text,
                //     fontSize: currentTheme.fontSize,
                //   ),
                // ),
                const Divider(
                  height: 15,
                  thickness: 3,
                ),
                Text(AppLocalizations.of(context)!.accountSettings,
                    style: TextStyle(
                      fontSize: currentTheme.fontSize - 4,
                      color: currentTheme.offColor,
                    )),
                createBottomSheetButton(
                  AppLocalizations.of(context)!.representative,
                  representative,
                  //
                  account,
                ),
                const Divider(
                  height: 15,
                  thickness: 2,
                ),

                // ------------------------------------
                Text(AppLocalizations.of(context)!.appSettings,
                    style: TextStyle(
                      fontSize: currentTheme.fontSize - 4,
                      color: currentTheme.offColor,
                    )),
                // createDialogButton("Currency", "1", ThemesDialog()),
                // createDialogButton("Min. to receive", "1", ThemesDialog()),

                // Already done and working.
                // createDialogButton("PoW Source", selectedPoWName, PoWDialog()),

                // createDialogButton("Block Explorer", "1", ThemesDialog()),
                // createDialogButton("Data Source", "1", ThemesDialog()),

                createDialogButton(AppLocalizations.of(context)!.themes,
                    activeTheme, ThemesDialog()),
                createDialogButton(AppLocalizations.of(context)!.security, "",
                    SecurityDialog()),

                createDialogButton(AppLocalizations.of(context)!.language,
                    activeLanguage, LangDialog()),
                // createDialogButton("Contacts/Bookmark", "1", ThemesDialog()),
                // createDialogButton("Notifications", "1", ThemesDialog()),
                // createDialogButton("switch to nano?", "1", ThemesDialog()),
                ////////////////////////////////
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      resetFn();
                    },
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            AppLocalizations.of(context)!.resetApp,
                            style: TextStyle(
                              color: currentTheme.text,
                              fontSize: currentTheme.fontSize,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                /////////////////
              ],
            ),
          ),
        ),
      ),
    );
  }

  resetFn() async {
    // if (kDebugMode) {
    //   print("1111111111111111111111111111111111111111111111111111111");
    // }
    services<DBManager>().deleteDatabase();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => InitialPageOne()),
        ModalRoute.withName("/initialpageone"));
  }

  Widget newBottomSheetButton(
      String label, String peekActive, Widget dialogWidget) {
    double height = MediaQuery.of(context).size.height;
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    return TextButton(
      child: Column(
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: currentTheme.text,
                fontSize: currentTheme.fontSize,
              ),
            ),
          ),
          const SizedBox(
            height: 2,
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              peekActive,
              style: TextStyle(
                color: currentTheme.textDisabled,
                fontSize: currentTheme.fontSize - 6,
              ),
            ),
          ),
        ],
      ),
      onPressed: () {
        showModalBottomSheet<void>(
          enableDrag: true,
          isScrollControlled: true,
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          builder: (BuildContext context) {
            var statusBarHeight = MediaQuery.of(context).viewPadding.top;

            return SafeArea(
              minimum: EdgeInsets.only(
                top: (statusBarHeight == 0.0 ? 50 : statusBarHeight),
              ),
              child: Container(
                color: currentTheme.secondary,
                child: SizedBox(
                  height: height, // - 160,
                  child: Center(
                    child: Column(
                      children: [
                        /*
                        Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(top: 10),
                          height: 5,
                          width: MediaQuery.of(context).size.width * 0.15,
                          decoration: BoxDecoration(
                            // ==== TO CHANGE ===
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                        ),
                        */
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text("back arrow?"),
                            Padding(
                              padding: const EdgeInsets.only(
                                right: 10,
                              ),
                              child: SizedBox(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(context);
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
                        const SizedBox(
                          height: 30,
                        ),
                        dialogWidget,
                      ],
                    ),
                    // child: Column(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   mainAxisSize: MainAxisSize.min,
                    //   children: <Widget>[
                    //     WalletManagementDialog(),
                    //     ElevatedButton(
                    //       child: const Text('Close'),
                    //       onPressed: () => Navigator.pop(context),
                    //     ),
                    //   ],
                    // ),
                  ),
                ),
              ),
            );
          },
        );
        setState(() {});
      },
    );
  }

  /// creates a button that display a dialog to choose an item and peek at the active item
  ///
  /// @param label        - button label
  /// @param peekActive   - active item
  /// @param dialogWidget - the dialog displayed
  ///
  /// returns a widget button
  Widget createDialogButton(
      String label, String peekActive, Widget dialogWidget) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);

    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => Dialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25))),
              backgroundColor: currentTheme.primary,
              child: dialogWidget, // -- CHANGE LATER
            ),
          );
        },
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: TextStyle(
                  color: currentTheme.text,
                  fontSize: currentTheme.fontSize,
                ),
              ),
            ),
            const SizedBox(
              height: 2,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                peekActive,
                style: TextStyle(
                  color: currentTheme.textDisabled,
                  fontSize: currentTheme.fontSize - 6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// creates a button that display a bottomsheet to choose an item and peek at the active item
  ///
  /// @param label        - button label
  /// @param peekActive   - active item
  /// @param account      - account
  ///
  /// returns a widget button
  Widget createBottomSheetButton(
      String label, String peekActive, Account account) {
    BaseTheme currentTheme = watchOnly((ThemeModel x) => x.curTheme);

    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () async {
          changeRepPage(currentTheme, account, peekActive);
        },
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: TextStyle(
                  color: currentTheme.text,
                  fontSize: currentTheme.fontSize,
                ),
              ),
            ),
            const Gap(2),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                peekActive,
                style: TextStyle(
                  color: currentTheme.textDisabled,
                  fontSize: currentTheme.fontSize - 6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> changeRepPage(
      BaseTheme currentTheme, Account account, String activeRep) async {
    // final LocalAuthentication auth = LocalAuthentication();

    var appLocalizations = AppLocalizations.of(context);

    await services<UserData>().updateRepresentatives();

    Representative? rep = get<UserData>().getRepData(account.representative);

    List<Representative> repList = watchOnly((UserData x) => x.representatives);
    String repName = rep?.alias ?? "";
    String score = (rep?.score != null ? "Score: ${rep?.score}/100" : "");

    double height = MediaQuery.of(context).size.height;
    return showModalBottomSheet<void>(
        enableDrag: true,
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        backgroundColor: currentTheme.primary,
        builder: (BuildContext context) {
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
                  // color: currentTheme.primary,
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
                                        Navigator.of(context).pop(context);
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
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              AutoSizeText(
                                                repName,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  color: currentTheme.text,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              AutoSizeText(
                                                score,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  color: currentTheme.text,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),

                                          const Gap(10),
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

                                const Gap(80),

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
                                                  await selectRepresentativeFromListDialog(
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
                                              print("meow");
                                              setState(() {});
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

                                // createSendButton(account, currentTheme,
                                //     appLocalizations, width),
                                // const SizedBox(
                                //   height: 10,
                                // ),
                                // createQRButton(currentTheme,
                                //     appLocalizations, width),
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

  final ScrollController controller = ScrollController();

  Future<bool?> selectRepresentativeFromListDialog(
      BuildContext context,
      BaseTheme currentTheme,
      AppLocalizations? appLocalizations,
      List<Representative> repList,
      Account account) {
    return showDialog<bool>(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        double height = MediaQuery.of(context).size.height;
        double width = MediaQuery.of(context).size.width;
        return StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setState) {
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              // key: ValueKey(
              //     isCheckedNewWallet),
              backgroundColor: currentTheme.primary,
              elevation: 2,
              title: Center(
                child: Text(
                  "Representatives",
                  style: TextStyle(
                    fontSize: 24,
                    color: currentTheme.text,
                  ),
                ),
              ),
              titleTextStyle: currentTheme.textStyle,
              contentPadding: const EdgeInsets.only(top: 15),
              content: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: currentTheme.secondary,
                  borderRadius: const BorderRadius.all(Radius.circular(40.0)),
                ),
                child: SizedBox(
                  height: height * 0.65,
                  width: double.maxFinite,
                  child: Column(
                    children: [
                      Expanded(
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            dragDevices: {
                              PointerDeviceKind.touch,
                              PointerDeviceKind.mouse,
                            },
                          ),
                          child: GlowingOverscrollIndicator(
                            axisDirection: AxisDirection.down,
                            color: currentTheme.text,
                            child: ListView.builder(
                              controller: controller,
                              // physics: const ClampingScrollPhysics(),
                              physics: const AlwaysScrollableScrollPhysics(),

                              shrinkWrap: true,
                              itemCount: repList.length,

                              itemBuilder: (context, index) {
                                return _buildButtonColumn(
                                    context,
                                    repList[index],
                                    index,
                                    currentTheme,
                                    account,
                                    appLocalizations);
                              },
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 40,
                        width: width,
                        child: TextButton(
                          style: ButtonStyle(
                            overlayColor: MaterialStateColor.resolveWith(
                                (states) => currentTheme.text.withOpacity(0.3)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                              ),
                            ),
                            backgroundColor: MaterialStateProperty.all(
                              currentTheme.primary,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            // 'Yes',
                            appLocalizations?.cancel ?? "",
                            style: TextStyle(
                              color: currentTheme.text,
                              fontSize: currentTheme.fontSize,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // actionsAlignment: MainAxisAlignment.center,
              // actions: [
              //
              // ],
            );
          },
        );
      },
    );
  }

  Widget _buildButtonColumn(BuildContext context, Representative rep, int index,
      BaseTheme currentTheme, Account account, appLocalizations) {
    double width = MediaQuery.of(context).size.width;

    // double height = MediaQuery.of(context).size.height;

    String repAliasOrAddress = rep.alias ?? Utils().shortenAccount(rep.address);

    String score = "Score: ${rep.score}/100";
    String votingWeight =
        "Voting weight: ${rep.weightPercentage.toStringAsFixed(2)}";

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: currentTheme.primary,
          ),
          child: TextButton(
            style: ButtonStyle(
              overlayColor: MaterialStateColor.resolveWith(
                  (states) => currentTheme.text.withOpacity(0.05)),
              padding: MaterialStateProperty.all<EdgeInsets>(
                EdgeInsets.zero,
              ),
              minimumSize: MaterialStateProperty.all<Size>(const Size(50, 30)),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () async {
              print("on click ${rep.address}");
              bool canauth = await BiometricUtil().canAuth();
              bool verified = false;

              if (!canauth) {
                verified = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => VerifyPIN(),
                      ),
                    ) ??
                    false;
              } else {
                verified = await BiometricUtil().authenticate("UPDATE ME");
                //appLocalizations.authMsgWalletDel);
              }

              if (verified) {
                LoadingIndicatorDialog()
                    .show(context, text: "Changing representative...");

                bool result = await account.changeRepresentative(rep.address);
                LoadingIndicatorDialog().dismiss();
                if (result) {
                  Navigator.of(context).pop(true);

                  // Navigator.of(context).popUntil((route) => route.isFirst);
                }
              }
            },
            child: Center(
              child: Container(
                padding: const EdgeInsetsDirectional.fromSTEB(6, 2, 6, 2),
                margin: const EdgeInsetsDirectional.only(bottom: 1.0),
                height: 75,
                child: Column(
                  children: [
                    Ink(
                      height: 70,
                      width: width / 1.1,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AutoSizeText(
                              repAliasOrAddress,
                              maxLines: 1,
                              style: TextStyle(
                                color: currentTheme.text,
                                fontSize: 18,
                              ),
                            ),
                            const Gap(5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AutoSizeText(
                                  votingWeight,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: currentTheme.text,
                                    fontSize: 12,
                                  ),
                                ),
                                AutoSizeText(
                                  score,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: currentTheme.text,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          height: 1,
          color: currentTheme.secondary,
        )
      ],
    );
  }

  Widget createPrimaryDrawerButton(
      String label, String peekActive, Widget pageRoute) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);

    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () async {
          // showDialog(
          //   context: context,
          //   builder: (BuildContext context) => Dialog(
          //     shape: const RoundedRectangleBorder(
          //         borderRadius: BorderRadius.all(Radius.circular(25))),
          //     backgroundColor: currentTheme.primary,
          //     child: dialogWidget, // -- CHANGE LATER
          //   ),
          // );

          await Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) => pageRoute,
                ),
              )
              .then((value) => setState(() {}));
          setState(() {});
        },
        child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  color: currentTheme.text,
                  fontSize: currentTheme.fontSize,
                ),
              ),
            ),
            const SizedBox(
              height: 2,
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                peekActive,
                style: TextStyle(
                  color: currentTheme.textDisabled,
                  fontSize: currentTheme.fontSize - 6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
