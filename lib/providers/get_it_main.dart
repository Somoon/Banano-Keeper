// ignore_for_file: unused_import

import 'package:bananokeeper/db/dbManager.dart';
import 'package:bananokeeper/providers/localization_service.dart';
import 'package:bananokeeper/providers/pow_source.dart';
import 'package:bananokeeper/providers/queue_service.dart';
import 'package:bananokeeper/providers/shared_prefs_service.dart';
import 'package:bananokeeper/providers/user_data.dart';
import 'package:bananokeeper/providers/wallet_service.dart';
import 'package:bananokeeper/providers/wallets_service.dart';
import 'package:bananokeeper/themes.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'account.dart';

GetIt services = GetIt.instance;

void initServices() {
  services.registerSingleton<WalletsService>(WalletsService());
  services.registerSingleton<ThemeModel>(ThemeModel());
  services.registerSingleton<LocalizationModel>(LocalizationModel());
  services.registerSingleton<UserData>(UserData());
  services.registerSingleton<DBManager>(DBManager());
  services.registerSingleton<PoWSource>(PoWSource());
  services.registerSingleton<QueueService>(QueueService());

  // services.registerSingleton<SharedPrefsModel>(SharedPrefsModel());
  // services.registerSingletonAsync<SharedPrefsModel>(() => SharedPrefsModel());

  // services.registerSingletonAsync<SharedPreferences>(
  //     () => SharedPreferences.getInstance());
}

void resetServices() {
  services<SharedPrefsModel>().clearAll();

  if (services.isRegistered<WalletsService>())  services.unregister<WalletsService>();
  if (services.isRegistered<ThemeModel>()) services.unregister<ThemeModel>();
  if (services.isRegistered<LocalizationModel>()) services.unregister<LocalizationModel>();
  if (services.isRegistered<SharedPrefsModel>()) services.unregister<SharedPrefsModel>();
  if (services.isRegistered<UserData>()) services.unregister<UserData>();
  if (services.isRegistered<DBManager>()) services.unregister<DBManager>();
  if (services.isRegistered<PoWSource>()) services.unregister<PoWSource>();
  if (services.isRegistered<QueueService>()) services.unregister<QueueService>();
  if (services.isRegistered<WalletService>()) services.unregister<WalletService>();
  if (services.isRegistered<Account>()) services.unregister<Account>();
}