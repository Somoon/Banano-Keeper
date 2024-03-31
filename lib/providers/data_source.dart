// import 'package:bananokeeper/providers/get_it_main.dart';
// import 'package:bananokeeper/providers/user_data.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/shared_prefs_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DataSource extends ChangeNotifier {
  Map<String, String> listOfAPIs = {
    "Moonano": "https://api.moonano.net/banano",
    "Creeper": "https://api.creeper.banano.cc/banano",
    "Banano.trade": "https://spyglass.banano.trade/banano",
    "Spyglass": "https://api.spyglass.pw/banano",
  };

  String apiName = 'Moonano';

  void setAPI(api) {
    switch (api) {
      case "Creeper":
        apiName = "Creeper";
      case "Banano.trade":
        apiName = "Banano.trade";
      case "Spyglass":
        apiName = "Spyglass";
      case "Moonano":
      default:
        apiName = "Moonano";
    }
    if (kDebugMode) {
      print("node_select: setAPI: switched api to $api");
    }
    notifyListeners();
  }

  String getAPIName() {
    return apiName;
  }

  String getAPIURL() {
    String api = listOfAPIs[apiName]!;
    return api;
  }

  apiIndex(name) {
    return listOfAPIs.values.toList().indexWhere((element) => element == name);
  }

  apiKey(index) {
    return listOfAPIs.keys.elementAt(index);
  }

  //will use this when a (remote) source is down/unresponsive
  switchNode() {
    int selectedIndex = apiIndex(getAPIName());
    if (listOfAPIs.length - 1 == selectedIndex) {
      String newAPI = apiKey(0);
      setAPI(newAPI);
      services<SharedPrefsModel>().saveDataSource(newAPI);
    } else {
      String newAPI = apiKey(selectedIndex + 1);
      setAPI(newAPI);
      services<SharedPrefsModel>().saveDataSource(newAPI);
    }
  }
}
