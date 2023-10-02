import 'package:auto_size_text/auto_size_text.dart';
import 'package:bananokeeper/api/currency_conversion.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/user_data.dart';
import 'package:custom_platform_device_id/platform_device_id.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nanodart/nanodart.dart';
import 'package:decimal/decimal.dart';

class Utils {
  BigInt banRaw = BigInt.parse('100000000000000000000000000000');
  BigInt rawPerNano = BigInt.from(10).pow(29);

  rawFromAmount(String amount) {
    Decimal asDecimal = Decimal.parse(amount);
    Decimal rawDecimal = Decimal.parse(banRaw.toString());
    return (asDecimal * rawDecimal).toString();
  }

  /// Convert raw to ban and return as BigDecimal
  ///
  /// @param raw 100000000000000000000000000000
  /// @return Decimal value 1.000000000000000000000000000000
  ///
  Decimal amountFromRaw(String raw) {
    Decimal amount = Decimal.parse(raw.toString());
    var a = Decimal.parse(rawPerNano.toString());
    Decimal result = (amount / a).toDecimal();
    return result;
  }

  String shortenAccount(String banAddress, [longer = false]) {
    var shorted = banAddress;
    if (banAddress.length == 64) {
      if (longer) {
        shorted =
            "${banAddress.substring(0, 24)}...${banAddress.substring(50, 64)}";
      } else {
        shorted =
            "${banAddress.substring(0, 16)}...${banAddress.substring(56, 64)}";
      }
    }
    return shorted;
  }

  Widget colorffix(String banAddress, currentTheme) {
    if (banAddress.length == 64) {
      Widget str = RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: banAddress.substring(0, 16),
              style: TextStyle(
                color: currentTheme.text,
                fontSize: currentTheme.fontSize - 5,
                height: 1.3,
                fontFamily: 'monospace',
              ),
            ),
            TextSpan(
              text: banAddress.substring(17, 55),
              style: TextStyle(
                color: currentTheme.textDisabled,
                fontSize: currentTheme.fontSize - 5,
                height: 1.3,
                fontFamily: 'monospace',
              ),
            ),
            TextSpan(
              text: banAddress.substring(56, 64),
              style: TextStyle(
                color: currentTheme.text,
                fontSize: currentTheme.fontSize - 5,
                height: 1.3,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      );

      return str;
    }
    return AutoSizeText(
      banAddress,
      maxLines: 2,
      style: TextStyle(
        color: currentTheme.text,
        fontSize: currentTheme.fontSize,
        height: 1.3,
        fontFamily: 'monospace',
      ),
    );
  }

  getDeviceID() async {
    String? deviceId = "000";
    try {
      deviceId = await PlatformDeviceId.getDeviceId;
    } on PlatformException {
      if (kDebugMode) {
        print('getDeviceID ERROR');
      }
      deviceId = 'Failed to get deviceId.';
    }
    return deviceId;
  }

  Future<String> encryptSeed(seed, [String? dID]) async {
    dID = await Utils().getDeviceID();
    String password = dID!;

    Uint8List encrypted = NanoCrypt.encrypt(seed, password);
    String encryptedSeedHex = NanoHelpers.byteToHex(encrypted);
    return encryptedSeedHex;
  }

  Future<String> decryptSeed(encryptedSeed, [String? dID]) async {
    dID = await Utils().getDeviceID() ?? "";
    String password = dID!;
    Uint8List decrypted;
    String seed;
    try {
      decrypted =
          NanoCrypt.decrypt(NanoHelpers.hexToBytes(encryptedSeed), password);
      seed = NanoHelpers.byteToHex(decrypted);
    } on Exception catch (_) {
      seed = "false";
    }

    return seed;
  }

  Widget getMonkey(String address) {
    return FadeInImage.assetNetwork(
      image: 'https://imgproxy.moonano.net/$address',
      placeholder: 'images/greymonkey.png',
      width: 50,
      fit: BoxFit.fill,
      imageErrorBuilder:
          (BuildContext context, Object exception, StackTrace? stackTrace) {
        return const Image(
          image: AssetImage('images/greymonkey.png'),
          width: 50,
        );
      },
    );
  }

  String displayNums(String number) {
    return amountFromRaw(number).toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  Widget formatBalance(
      activeAccountBalance, currentTheme, String userCurrency) {
    // String userCurrency = services<UserData>().currency;
    Decimal convertedPrice = Decimal.parse(
            services<CurrencyConversion>().price[userCurrency]!.toString()) *
        amountFromRaw(activeAccountBalance);
    String textC =
        "${services<CurrencyConversion>().symbol[userCurrency]}${convertedPrice.toStringAsFixed(2)}";
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        //Center Row contents horizontally,
        crossAxisAlignment: CrossAxisAlignment.center,
        //Center Row contents vertically,
        children: <Widget>[
          // ------------------ change image Icons between BANANO/XNO
          Image.asset(
            width: 12,
            'images/banano.png',
          ),
          const SizedBox(
            width: 4,
          ),
          Text(
            displayNums(activeAccountBalance),
            style: TextStyle(color: currentTheme.text),
          ),
          GestureDetector(
            onTap: () {
              print("asd");

              services<UserData>().switchCurrency();
              //change currency showing here ------------------------
            },
            child: Text(
              " ($textC)",
              style: TextStyle(color: currentTheme.offColor),
            ),
          ),
        ]);
  }

  //ban:ban_1iya1arzbggdiwukjsqhqjcdg13n8wm84camby8hd91o1kpzbsnd8sai5gh4?amount=768000000000000000000000
  //banano:ban_1hpgfkej3jqfci5rwwofqa1r3ckipc7i69z1wgztps4hzed3mq11ow5op5i5?amount=705000000000000000000000000000
  //for deep links too?
  getQRCodeData(String? value) {
    Map<String, String> qRData = {"address": "", "amountRaw": ""};
    if (value != null) {
      value = value.toLowerCase();
      qRData['address'] =
          NanoAccounts.findAccountInString(NanoAccountType.BANANO, value) ?? "";
      var split = value.split('?amount=');
      if (split.length > 1) {
        Uri? uri = Uri.tryParse(value);
        if (uri != null && uri.queryParameters['amount'] != null) {
          qRData['amountRaw'] = uri.queryParameters['amount']!;
        }
      }
    }
    return qRData;
  }

  generateSeed() {
    return NanoSeeds.generateSeed();
  }

  bool isDirectionRTL(BuildContext context) {
    return (Directionality.of(context).index == 0);
  }
}
