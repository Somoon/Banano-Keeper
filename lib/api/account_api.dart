import 'dart:async';

import 'package:bananokeeper/api/state_block.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/pow/local_work.dart';
import 'package:bananokeeper/providers/pow/node_selector.dart';
import 'package:bananokeeper/providers/pow/pow_source.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AccountAPI {
  getHistory(String address, [int size = 25, offset = 0]) async {
    String apiURL =
        'https://api.spyglass.pw/banano/v2/account/confirmed-transactions';

    http.Response response = await http.post(
      Uri.parse(apiURL),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'address': address,
        "includeChange": true,
        "includeReceive": true,
        "includeSend": true,
        "offset": offset,
        "size": size
      }),
    );
    return response;
  }

  getOverview(String address) async {
    // print('ACCOUNT_API: GETOVERVIEW:');

    String apiURL =
        'https://api.spyglass.pw/banano/v1/account/overview/$address';
    http.Response response = await http.get(
      Uri.parse(apiURL),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    return response;
  }

  getReceivables(String address, [size = 10]) async {
    String apiURL =
        'https://api.spyglass.pw/banano/v1/account/receivable-transactions';
    http.Response response = await http.post(
      Uri.parse(apiURL),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'address': address,
        'size': size,
      }),
    );

    return response;
  }

  processRequest(StateBlock block, String subtype,
      [String publicKey = '']) async {
    String powType = services<PoWSource>().getAPIName();
    String nodeURL = services<PoWSource>().getNodeURL();

    //if pow pre-generated before sending, use user's set node
    if (powType == "Local PoW")
    // || Bpow
    //)
    {
      nodeURL = services<NodeSelector>().getNodeURL();
    }
    /*
    if powType local OR bpow
    -> get node from node_selector
       nodeURL
     */

    Map<String, dynamic> request = {};
    if (powType == 'Local PoW') {
      LocalWork lPow = services<LocalWork>();
      // await lPow.init();

      lPow.completer = Completer<String>();
      String hashForWork = (subtype == 'open' ? publicKey : block.previous);
      lPow.generateWork(
        hash: hashForWork,
      );
      String fetchedWork = await lPow.completer.future;
      // print(fetchedWork);
      block.work = fetchedWork;

      request = {
        "action": "process",
        "block": json.encode(block.toJson()),
        "subtype": subtype
      };
      // }
    } else {
      request = {
        "action": "process",
        "block": json.encode(block.toJson()),
        "do_work": true,
        "subtype": subtype
      };
    }
    if (kDebugMode) {
      print("processRequest $nodeURL");
    }

    http.Response response = await http.post(
      Uri.parse(nodeURL),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(request),
    );
    if (response.statusCode != 200) {
      if (kDebugMode) {
        print("ERR code ${response.statusCode}");
      }
    }
    Map decoded = json.decode(response.body);
    if (decoded.containsKey("error")) {
      if (kDebugMode) {
        print("ERR $decoded");
      }
    }

    // print(response.statusCode);
    // if (kDebugMode) {
    //   print(response.body);
    // }
    return response.body;
  }

  getRepresentatives() async {
    String apiURL = 'https://api.spyglass.pw/banano/v1/representatives/scores';
    http.Response response = await http.get(
      Uri.parse(apiURL),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    return response;
  }
}
