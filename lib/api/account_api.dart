import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/pow_source.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AccountAPI {
  getHistory(String address, [int count = 10]) async {
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
        "size": count
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

  processRequest(block, subtype) async {
    String apiURL = services<PoWSource>().getAPIURL();
    if (kDebugMode) {
      print("processRequest $apiURL");
    }
    Map<String, dynamic> request = {
      "action": "process",
      "block": json.encode(block),
      "do_work": true,
      "subtype": subtype
    };
    if (kDebugMode) {
      print(request);
    }
    http.Response response = await http.post(
      Uri.parse(apiURL),
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
    if (kDebugMode) {
      print(response.body);
    }
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
