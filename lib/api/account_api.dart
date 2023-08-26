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

  getReceivables(String address) async {
    String apiURL =
        'https://api.spyglass.pw/banano/v1/account/receivable-transactions';
    http.Response response = await http.post(
      Uri.parse(apiURL),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'address': address,
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
    // print(response.body);
    return response.body;
  }

  /*
      // RECEIVE

      onPressed: () async {
                //get current balance
                var accOverview = await getOverview(account);
                var accOverviewData = jsonDecode(accOverview.body);
                balance = accOverviewData['balanceRaw'];
                var recRes = await getReceivables(account);

                //get receivables (can be done to receive multi at once)
                // maybe put this step within the receiveAll loop or just after with this in mind
                // we save the whole response, this loop through it and we start with
                // OGbal + first, for second loop newBal + secondBal....
                // and we keep creating new blocks and process then after each process WE TAKE/STORE THE PROCESS HASH since its the latest and used for next receiable
                // print(recRes.body);
                var data = jsonDecode(recRes.body);
                var receivableHash = data[0]['hash'];
                var receivableRaw = data[0]['amountRaw'];

                var hist = await getHistory(account, 1);
                var historyData = jsonDecode(hist.body);
                previous = historyData[0]['hash'];

                var newRaw =
                    (BigInt.parse(receivableRaw) + BigInt.parse(balance))
                        .toString();

                var sign = await createOpenBlock(account, previous,
                    representative, newRaw, receivableHash, privateKey);

                print(sign);

                Map<String, dynamic> block = {
                  "type": "state",
                  "account": account,
                  "previous": previous,
                  "representative": representative,
                  "balance": newRaw,
                  "link": receivableHash,
                  "signature": sign,
                  // "private"
                };
                processRequest(block, "receive");

                }.

                /////////////////////////////////////////////////

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


  String zeros = "".padLeft(64, "0");



                /////// FUNCTIONS

        String type = "state";
  String account =
      "ban_1fcyrps8j5uokeah34ud531nuu9wkqrb9xkkadk8qinefx11c6oxeia5utbk";
  String previous =
      '0000000000000000000000000000000000000000000000000000000000000000';
  String representative =
      "ban_1moonanoj76om1e9gnji5mdfsopnr5ddyi6k3qtcbs8nogyjaa6p8j87sgid";

  // balance in raw AFTER adding new receivable amount to balance
  BigInt balance = BigInt.parse('1');

  String privateKey =
      "F5009F7574EEB927FF7F1255C9560069151EAF2D4F7B15B1736549CD4CF4E4D7";

  //receivable block hash from getReceiveAbles
  String link = "";

  ///////////////

  String _SERVER_ADDRESS_HTTP = "https://kaliumapi.appditto.com/api";

  getReceivables(String address) async {
    print(address);
    String apiURL =
        'https://api.spyglass.pw/banano/v1/account/receivable-transactions';
    http.Response response = await http.post(
      Uri.parse(apiURL),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'address': address,
      }),
    );

    return response;
  }

  createOpenBlock(String accountAddress, String previous, String rep,
      receivableBalanceRaw, linkAsReceivableBlockHash, privateKey) {
    int accountType = NanoAccountType.BANANO;
    String calculatedHash = NanoBlocks.computeStateHash(
        accountType,
        accountAddress,
        previous,
        rep,
        BigInt.parse(receivableBalanceRaw),
        linkAsReceivableBlockHash);
    // Signing a block
    return NanoSignatures.signBlock(calculatedHash, privateKey);
  }

  // Future<dynamic> makeHttpRequest(BaseRequest request) async {
  //   http.Response response = await http.post(Uri.parse(_SERVER_ADDRESS_HTTP),
  //       headers: {'Content-type': 'application/json'},
  //       body: json.encode(request.toJson()));
  //   if (response.statusCode != 200) {
  //     return null;
  //   }
  //   Map decoded = json.decode(response.body);
  //   if (decoded.containsKey("error")) {
  //     return ErrorResponse.fromJson(decoded);
  //   }
  //   return decoded;
  // }

//subtype: BlockTypes.OPEN,
//         previous: "0",
//         representative: representative,
//         balance: balance,
//         link: link,
//         account: account,
//         privKey: privKey);

  processRequest(block) async {
    Map<String, dynamic> request = {
      "action": "process",
      "block": json.encode(block),
      "do_work": true,
      "subtype": "open"
    };
    print(request);
    http.Response response = await http.post(
      Uri.parse(_SERVER_ADDRESS_HTTP),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(request),
    );

    print(response);
    print(response.body);
    return response;
  }





   */
}
