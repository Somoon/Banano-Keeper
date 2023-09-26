// import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bananokeeper/db/dbManager.dart';
import 'package:bananokeeper/db/dbtest.dart';
import 'package:bananokeeper/initial_pages/initial_page_one.dart';
import 'package:bananokeeper/providers/account.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/pow_source.dart';
import 'package:bananokeeper/providers/shared_prefs_service.dart';
import 'package:bananokeeper/providers/wallet_service.dart';
import 'package:bananokeeper/providers/wallets_service.dart';
import 'package:bananokeeper/ui/changeRepBottomSheet.dart';
import 'package:bananokeeper/ui/dialogs/pow_dialog.dart';
import 'package:bananokeeper/ui/dialogs/security_dialog.dart';
import 'package:bananokeeper/ui/dialogs/themes_dialog.dart';
import 'package:bananokeeper/ui/management/management_address_page.dart';
import 'package:bananokeeper/ui/management/management_page.dart';
import 'package:bananokeeper/ui/management/management_wallet_page.dart';
import 'package:bananokeeper/ui/pin/setup_pin.dart';
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
                  account.getRep(),
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
          changeRepPage(currentTheme, account);
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

  Future<void> changeRepPage(BaseTheme currentTheme, Account account) {
    // final LocalAuthentication auth = LocalAuthentication();

    var appLocalizations = AppLocalizations.of(context);
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
                                const Gap(20),
                                AutoSizeText(
                                  "Current Rep:",
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: currentTheme.text,
                                  ),
                                ),
                                const Gap(10),
                                AutoSizeText(
                                  "rep name if exist here",
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: currentTheme.text,
                                  ),
                                ),
                                const Gap(5),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 15.0,
                                    right: 15.0,
                                  ),
                                  child: AutoSizeText(
                                    account.getRep(),
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: currentTheme.text,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                                // Padding(
                                //   padding: const EdgeInsets.only(
                                //       left: 25, right: 25),
                                //   child: Utils().colorffix(
                                //       account.address, currentTheme),
                                // ),
                                const Gap(20),

                                // sendAddressTextField(
                                //     currentTheme, context),
                                // const SizedBox(
                                //   height: 20,
                                // ),

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
