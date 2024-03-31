import 'dart:io';

import 'package:bananokeeper/db/dbManager.dart';
import 'package:bananokeeper/providers/account.dart';
import 'package:bananokeeper/providers/data_source.dart';
import 'package:bananokeeper/providers/localization_service.dart';
import 'package:bananokeeper/providers/pow/local_work.dart';
import 'package:bananokeeper/providers/pow/node_selector.dart';
import 'package:bananokeeper/providers/pow/pow_source.dart';
import 'package:bananokeeper/providers/queue_service.dart';
import 'package:bananokeeper/providers/shared_prefs_service.dart';
import 'package:bananokeeper/providers/user_data.dart';
import 'package:bananokeeper/providers/wallet_service.dart';
import 'package:bananokeeper/providers/wallets_service.dart';
import 'package:bananokeeper/themes.dart';
import 'package:get_it/get_it.dart';

GetIt services = GetIt.instance;

void initServices() {
  services.registerSingleton<WalletsService>(WalletsService());
  services.registerSingleton<ThemeModel>(ThemeModel());
  services.registerSingleton<LocalizationModel>(LocalizationModel());
  services.registerSingleton<UserData>(UserData());
  services.registerSingleton<DBManager>(DBManager());
  services.registerSingleton<PoWSource>(PoWSource());
  if (!Platform.isWindows) {
    services.registerSingleton<LocalWork>(LocalWork());
  }
  services.registerSingleton<NodeSelector>(NodeSelector());
  services.registerSingleton<QueueService>(QueueService());
  services.registerSingleton<DataSource>(DataSource());
}

void resetServices() {
  if (services.isRegistered<WalletsService>()) {
    services.unregister<WalletsService>();
  }
  if (services.isRegistered<ThemeModel>()) services.unregister<ThemeModel>();
  if (services.isRegistered<LocalizationModel>()) {
    services.unregister<LocalizationModel>();
  }
  if (services.isRegistered<SharedPrefsModel>()) {
    services.unregister<SharedPrefsModel>();
  }
  if (services.isRegistered<UserData>()) services.unregister<UserData>();
  if (services.isRegistered<DBManager>()) services.unregister<DBManager>();
  if (services.isRegistered<PoWSource>()) services.unregister<PoWSource>();
  if (services.isRegistered<QueueService>()) {
    services.unregister<QueueService>();
  }
  if (services.isRegistered<WalletService>()) {
    services.unregister<WalletService>();
  }
  if (services.isRegistered<Account>()) services.unregister<Account>();
  if (services.isRegistered<LocalWork>()) services.unregister<LocalWork>();
  if (services.isRegistered<DataSource>()) services.unregister<DataSource>();
  if (services.isRegistered<NodeSelector>()) {
    services.unregister<NodeSelector>();
  }
}
