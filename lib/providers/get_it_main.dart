// ignore_for_file: unused_import

import 'package:bananokeeper/db/dbManager.dart';
import 'package:bananokeeper/providers/localization_service.dart';
import 'package:bananokeeper/providers/pow_source.dart';
import 'package:bananokeeper/providers/queue_service.dart';
import 'package:bananokeeper/providers/shared_prefs_service.dart';
import 'package:bananokeeper/providers/user_data.dart';
import 'package:bananokeeper/providers/wallets_service.dart';
import 'package:bananokeeper/themes.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
