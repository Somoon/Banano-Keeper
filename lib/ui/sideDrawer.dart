// import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:bananokeeper/api/representative_json.dart';
import 'package:bananokeeper/db/dbManager.dart';
import 'package:bananokeeper/initial_pages/initial_page_one.dart';
import 'package:bananokeeper/providers/account.dart';
import 'package:bananokeeper/providers/auth_biometric.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/pow_source.dart';
import 'package:bananokeeper/providers/user_data.dart';
import 'package:bananokeeper/providers/wallet_service.dart';
import 'package:bananokeeper/providers/localization_service.dart';
import 'package:bananokeeper/providers/wallets_service.dart';
import 'package:bananokeeper/ui/dialogs/pow_dialog.dart';
import 'package:bananokeeper/ui/dialogs/security_dialog.dart';
import 'package:bananokeeper/ui/dialogs/themes_dialog.dart';
import 'package:bananokeeper/ui/management/management_address_page.dart';
import 'package:bananokeeper/ui/management/management_page.dart';
import 'package:bananokeeper/ui/management/management_wallet_page.dart';
import 'package:bananokeeper/ui/pin/verify_pin.dart';
import 'package:bananokeeper/ui/representative_pages/rep_page.dart';
import 'package:bananokeeper/ui/dialogs/lang_dialog.dart';
import 'package:bananokeeper/utils/utils.dart';
import 'package:bananokeeper/themes.dart';

import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:auto_size_text/auto_size_text.dart';

class SideDrawer extends StatefulWidget with GetItStatefulWidgetMixin {
  SideDrawer({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SideDrawer createState() => _SideDrawer();
}

class _SideDrawer extends State<SideDrawer>
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
    // String currentAccount = watchX((WalletService x) => x.currentAccount,
    //     instanceName: orgWalletName);

    int accountIndex = wallet.activeIndex;

    String accOrgName = wallet.accountsList[accountIndex];

    String accountName =
        watchOnly((Account x) => x.getName(), instanceName: accOrgName);

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
                  accountName,
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
                createRepBottomSheetButton(
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
                    activeLanguage['displayedLanguage']!, LangDialog()),
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
  Widget createRepBottomSheetButton(
      String label, String peekActive, Account account) {
    BaseTheme currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    Representative? rep = get<UserData>().getRepData(peekActive);

    String representativeAliasOrAddress = rep?.alias ?? peekActive;
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
                representativeAliasOrAddress,
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

  Future<bool?> changeRepPage(
      BaseTheme currentTheme, Account account, String activeRep) async {
    await services<UserData>().updateRepresentatives();

    Representative? rep = get<UserData>().getRepData(account.representative);

    List<Representative>? repList =
        watchOnly((UserData x) => x.representatives);
    String repName = rep?.alias ?? "";
    String score = (rep?.score != null
        ? AppLocalizations.of(context)!
            .repScore(rep?.score.toString() ?? "0.00")
        : "");

    var result = await RepPage().show(context, currentTheme, repName, score,
        activeRep, repList, account, rep);
    return result;
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
