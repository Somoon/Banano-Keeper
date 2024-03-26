// import 'package:bananokeeper/providers/get_it_main.dart';
// import 'package:bananokeeper/providers/user_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NodeSelector extends ChangeNotifier {
  //node used to send transaction block
  Map<String, String> listOfNodes = {
    "Kalium": "https://kaliumapi.appditto.com/api",
    "Booster": "https://booster.dev-ptera.com/banano-rpc",
    // "Moonano": "https://bnm.smn.sh/proxy", //not working yet
    "Banano.trade": "https://api.banano.trade/proxy",
    "Jungle TV": "https://public.node.jungletv.live/rpc",
  };

  String nodeName = 'Kalium';
  void setNode(api) {
    switch (api) {
      case "Moonano":
        nodeName = "Moonano";
      case "Booster":
        nodeName = "Booster";
      case "Banano.trade":
        nodeName = "Banano.trade";
      case "Jungle TV":
        nodeName = "Jungle TV";
      case "Kalium":
      default:
        nodeName = "Kalium";
    }
    if (kDebugMode) {
      print("node_select: setAPI: switched api to $api");
    }
    notifyListeners();
  }

  String getNodeName() {
    return nodeName;
  }

  String getNodeURL() {
    String api = listOfNodes[nodeName]!;
    return api;
  }

  apiIndex(name) {
    return listOfNodes.values.toList().indexWhere((element) => element == name);
  }

  apiKey(index) {
    return listOfNodes.keys.elementAt(index);
  }

  //will use this when a (remote) source is down/unresponsive
  switchNode() {
    int selectedIndex = apiIndex(getNodeName());
    // final value = listOfAPIS.values.elementAt(selectedIndex);
    if (listOfNodes.length - 1 == selectedIndex) {
      String newAPI = apiKey(0);
      setNode(newAPI);
    } else {
      String newAPI = apiKey(selectedIndex + 1);
      setNode(newAPI);
    }
  }
}
