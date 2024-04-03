import 'dart:convert';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bananokeeper/api/currency_conversion.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/shared_prefs_service.dart';
import 'package:bananokeeper/providers/user_data.dart';
import 'package:bananokeeper/utils/tnacl/tnacl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nanodart/nanodart.dart';
import 'package:decimal/decimal.dart';
import 'package:pointycastle/digests/blake2b.dart';
import 'package:pinenacl/tweetnacl.dart';
import 'dart:io';

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

  Widget colorffix(String banAddress, currentTheme, [double? fontSize]) {
    fontSize ??= currentTheme.fontSize;
    if (banAddress.length == 64) {
      Widget str = RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: banAddress.substring(0, 16),
              style: TextStyle(
                color: currentTheme.text,
                fontSize: fontSize! - 5,
                height: 1.3,
                fontFamily: 'monospace',
              ),
            ),
            TextSpan(
              text: banAddress.substring(17, 55),
              style: TextStyle(
                color: currentTheme.textDisabled,
                fontSize: fontSize - 5,
                height: 1.3,
                fontFamily: 'monospace',
              ),
            ),
            TextSpan(
              text: banAddress.substring(56, 64),
              style: TextStyle(
                color: currentTheme.text,
                fontSize: fontSize - 5,
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
        fontSize: fontSize,
        height: 1.3,
        fontFamily: 'monospace',
      ),
    );
  }

  String getRandString(int len) {
    var random = Random.secure();
    var values = List<int>.generate(len, (i) => random.nextInt(255));
    // return base64UrlEncode(values);
    return values.join();
  }

  Future<String> encryptSeed(seed, [String? dID]) async {
    String password = (dID == null)
        ? await services<SharedPrefsModel>().bioStorageFetchKey()
        : dID;

    Uint8List encrypted = NanoCrypt.encrypt(seed, password);
    String encryptedSeedHex = NanoHelpers.byteToHex(encrypted);
    return encryptedSeedHex;
  }

  Future<String> decryptSeed(encryptedSeed, [String? dID]) async {
    String password = (dID == null)
        ? await services<SharedPrefsModel>().bioStorageFetchKey()
        : dID;

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
    return amountFromRaw(number).toStringAsFixed(2);
  }

  String preciseValue(Decimal value) {
    RegExp regex = RegExp(r'([.]*0)(?!.*\d)');
    String amountNoTrail = value.toStringAsPrecision(3).replaceAll(regex, '');
    return amountNoTrail;
  }

  Widget formatBalance(
      activeAccountBalance, currentTheme, String userCurrency) {
    // String userCurrency = services<UserData>().currency;
    Decimal convertedPrice = Decimal.parse(
            services<CurrencyConversion>().price[userCurrency]!.toString()) *
        amountFromRaw(activeAccountBalance);
    /*
    Decimal convertedPrice = Decimal.parse(
            services<CurrencyConversion>().price[userCurrency]!.toString()) *
        amountFromRaw(activeAccountBalance);
    String textC =
        "${services<CurrencyConversion>().symbol[userCurrency]}${convertedPrice.toStringAsFixed(2)}";
     */

    String pValue = preciseValue(convertedPrice);
    String textC =
        "${services<CurrencyConversion>().symbol[userCurrency]}${(pValue)}";
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
              // print("asd");

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

  dissectDeepLink(String? value) {
    Map<String, String?> deepLinkData = {};
    if (value != null) {
      // value = value.toLowerCase();
      Uri? uri = Uri.tryParse(value);
      if (uri != null) {
        switch (uri.scheme) {
          case 'ban':
          case 'banano':
            deepLinkData = getQRCodeData(value);
            break;
          case 'banrep':
            deepLinkData['representative'] =
                NanoAccounts.findAccountInString(NanoAccountType.BANANO, value);
            break;
          case 'bansign':
            Map<String, String> splitQueries = Uri.splitQueryString(uri.path);

            deepLinkData['address'] = splitQueries['address'];

            deepLinkData['callback'] = splitQueries['url'];
            deepLinkData['url'] = splitQueries['url'];

            deepLinkData['message'] = splitQueries['message'];

            break;
          case 'banverify':
            deepLinkData['message'] = uri.queryParameters['message'];
            deepLinkData['sign'] = uri.queryParameters['sign'];
            deepLinkData['address'] =
                NanoAccounts.findAccountInString(NanoAccountType.BANANO, value);
            break;
        }
      }
    }

    return deepLinkData;
  }

  generateSeed() {
    return NanoSeeds.generateSeed();
  }

  bool isDirectionRTL(BuildContext context) {
    return (Directionality.of(context).index == 0);
  }

  String getDummyBlockHash(String account, String representative) {
    Uint8List statePreamble = NanoHelpers.hexToBytes(
        "0000000000000000000000000000000000000000000000000000000000000006");
    Uint8List accountBytes =
        NanoHelpers.hexToBytes(NanoAccounts.extractPublicKey(account));
    Uint8List previousBytes = NanoHelpers.hexToBytes("".padLeft(64, "0"));
    Uint8List representativeBytes = NanoHelpers.hexToBytes(representative);
    Uint8List balanceBytes = NanoHelpers.bigIntToBytes(BigInt.parse("0"));
    Uint8List linkBytes = NanoHelpers.hexToBytes("".padLeft(64, "0"));
    var a = Blake2b.digest256([
      statePreamble,
      accountBytes,
      previousBytes,
      representativeBytes,
      balanceBytes,
      linkBytes
    ]);
    return NanoHelpers.byteToHex(a).toUpperCase();
  }

  bool detachedVerify(
      Uint8List message, Uint8List signature, Uint8List publicKey) {
    int signatureLength = 64;
    int publicKeyLength = 32;
    if (signature.length != signatureLength) return false;
    if (publicKey.length != publicKeyLength) return false;
    Uint8List sm = Uint8List(signatureLength + message.length);
    Uint8List m = Uint8List(signatureLength + message.length);
    for (int i = 0; i < signatureLength; i++) sm[i] = signature[i];
    for (int i = 0; i < message.length; i++)
      sm[i + signatureLength] = message[i];

    return (TNaCl.cryptoSignOpen(m, sm, sm.length, publicKey) >= 0);
  }

  String bananoMessagePreamble = 'bananomsg-';

  String preamble =
      '0000000000000000000000000000000000000000000000000000000000000006';
  Uint8List DUMMY_BYTES = NanoHelpers.hexToBytes(
      '0000000000000000000000000000000000000000000000000000000000000000');
  Uint8List DUMMY_BALANCE =
      NanoHelpers.hexToBytes('00000000000000000000000000000000');

  getDumBlockHashBytes(Uint8List publicKeyBytes, message) {
    Uint8List messageBytes = NanoHelpers.stringToBytesUtf8(message);
    Uint8List bananoMessagePreambleBytes =
        NanoHelpers.stringToBytesUtf8(bananoMessagePreamble);

    Uint8List hashMessageToBytes = Uint8List(32);
    Blake2bDigest blake2b = Blake2bDigest(digestSize: 32);
    blake2b.update(
        bananoMessagePreambleBytes, 0, bananoMessagePreambleBytes.length);
    blake2b.update(messageBytes, 0, messageBytes.length);
    blake2b.doFinal(hashMessageToBytes, 0);

    //now the block
    Uint8List hashBytes = Uint8List(32);
    Blake2bDigest blake2bhashBytes = Blake2bDigest(digestSize: 32);
    blake2bhashBytes.update(NanoHelpers.hexToBytes(preamble), 0,
        NanoHelpers.hexToBytes(preamble).length);
    blake2bhashBytes.update(publicKeyBytes, 0, publicKeyBytes.length);
    blake2bhashBytes.update(DUMMY_BYTES, 0, DUMMY_BYTES.length);
    blake2bhashBytes.update(hashMessageToBytes, 0, hashMessageToBytes.length);
    blake2bhashBytes.update(DUMMY_BYTES, 0, DUMMY_BYTES.length);
    blake2bhashBytes.update(DUMMY_BALANCE, 0, DUMMY_BALANCE.length);
    blake2bhashBytes.doFinal(hashBytes, 0);
    return hashBytes;
  }
}
