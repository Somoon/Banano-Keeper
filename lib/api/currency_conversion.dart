import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/pow_source.dart';
import 'package:bananokeeper/providers/shared_prefs_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrencyAPI {
  getData() async {
    String apiURL = 'https://moonano.net/assets/data/prices.json';
    http.Response response = await http.get(
      Uri.parse(apiURL),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    return jsonDecode(response.body);
  }
}

class CurrencyConversion extends ChangeNotifier {
  Map<String, double> price = {
    "USD": 0.0,
    "GBP": 0.0,
    "XNO": 0.0,
    "BTC": 0.0,
  };
  Map<String, String> symbol = {
    "USD": "\$",
    "GBP": "£",
    "XNO": "Ӿ",
    "BTC": "฿"
  };

  Map<String, Map<String, String>> test = {
    "USD": {
      "price": "0.0",
      "symbol": "\$",
    },
    "GBP": {
      "price": "0.0",
      "symbol": "\$",
    },
  };

  updateData(data) {
    // test['USD']?['price'];
    // currencies = Map<String, double>.from(data);
    Map<String, double> _price = {
      "USD": data['USD']!,
      "GBP": data['GBP']!,
      "XNO": data['XNO']!,
      "BTC": data['BTC']!,
    };
    price = Map.from(_price);

    // services<SharedPrefsModel>().savePrices(price);
    // services<SharedPrefsModel>().getPrices();
    notifyListeners();
  }
}
