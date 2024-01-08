// import 'package:bananokeeper/providers/get_it_main.dart';
// import 'package:bananokeeper/providers/user_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PoWSource extends ChangeNotifier {
  //node used to send transaction block
  Map<String, String> listOfAPIS = {
    "Kalium": "https://kaliumapi.appditto.com/api",
    "Booster": "https://booster.dev-ptera.com/banano-rpc",
    "Local PoW": "https://kaliumapi.appditto.com/api", //for now like this
  };

  String apiName = 'Kalium';
  void setAPI(api) {
    switch (api) {
      case "Local PoW":
        // services<UserData>().setPoWSource(boosterAPI);
        apiName = "Local PoW";
      case "Booster":
        // services<UserData>().setPoWSource(boosterAPI);
        apiName = "Booster";

      case "Kalium":
      default:
        // services<UserData>().setPoWSource(kaliumAPI);
        apiName = "Kalium";
    }
    if (kDebugMode) {
      print("pow_source: setAPI: switched api to $api");
    }
    notifyListeners();
  }

  String getAPIName() {
    return apiName;
  }

  String getAPIURL() {
    var api = listOfAPIS[apiName];
    return api!;
  }

  apiIndex(name) {
    return listOfAPIS.values.toList().indexWhere((element) => element == name);
  }

  apiKey(index) {
    return listOfAPIS.keys.elementAt(index);
  }

  //will use this when a (remote) source is down/unresponsive
  switchAPI() {
    int selectedIndex = apiIndex(getAPIName());
    // final value = listOfAPIS.values.elementAt(selectedIndex);
    if (listOfAPIS.length - 1 == selectedIndex) {
      String newAPI = apiKey(0);
      setAPI(newAPI);
    } else {
      String newAPI = apiKey(selectedIndex + 1);
      setAPI(newAPI);
    }
  }
}

enum APIS { KALIUM, BOOSTER }
