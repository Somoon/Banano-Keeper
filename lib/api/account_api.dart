import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/pow_source.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AccountAPI {
  var history = [];

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
    print("processRequest $apiURL");
    Map<String, dynamic> request = {
      "action": "process",
      "block": json.encode(block),
      "do_work": true,
      "subtype": subtype
    };
    print(request);
    http.Response response = await http.post(
      Uri.parse(apiURL),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(request),
    );
    if (response.statusCode != 200) {
      print("ERR code ${response.statusCode}");
    }
    Map decoded = json.decode(response.body);
    if (decoded.containsKey("error")) {
      print("ERR $decoded");
    }

    // print(response.statusCode);
    print(response.body);
    return response.body;
  }

  /*
      onPressed: () async {
            //get current balance
            var accOverview = await getOverview(account);
            var accOverviewData = jsonDecode(accOverview.body);
            balance = accOverviewData['balanceRaw'];

            var hist = await getHistory(account, 1);
            var historyData = jsonDecode(hist.body);
            previous = historyData[0]['hash'];

            var newRaw = balance;

            var newRep =
                "ban_14xjizffqiwjamztn4edhmbinnaxuy4fzk7c7d6gywxigydrrxftp4qgzabh";
            var sign = await createOpenBlock(
                account, previous, newRep, newRaw, zeros, privateKey);

            print(sign);

            Map<String, dynamic> block = {
              "type": "state",
              "account": account,
              "previous": previous,
              "representative": newRep,
              "balance": newRaw,
              "link": zeros,
              "signature": sign,
              // "private"
            };
            processRequest(block, "change");
            //
            // await openBlock();
            // var a = await getHistory();
          },



   */
}
