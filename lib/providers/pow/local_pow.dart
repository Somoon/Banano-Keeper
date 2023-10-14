// import 'package:bananokeeper/providers/get_it_main.dart';
// import 'package:bananokeeper/providers/user_data.dart';
import 'dart:async';

import 'package:bananokeeper/api/account_api.dart';
import 'package:bananokeeper/api/state_block.dart';
import 'package:bananokeeper/db/dbtest.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class LocalPoW extends ChangeNotifier {
  Completer<String> completer = Completer<String>();
  ValueNotifier<String> work = ValueNotifier<String>('');
  late WebViewController controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..addJavaScriptChannel(
      "Print",
      onMessageReceived: (JavaScriptMessage jsChannel) {
        print(jsChannel.message);
        setWork(jsChannel.message);
        // controller.runJavaScript('window.stop();');
      },
    );
  //maybe have multi/different hosts in case one is down (gh?)
  String powScriptURL = 'https://moonano.net/assets/data/pow/multiThread.html';

//   setWork(String foundWork) {
//     work.value = foundWork;
//     print('DONE!!!! $foundWork');
//     //force stop the work
//     controller.loadRequest(Uri.parse('about:blank'));
//     // callBackFn(work.value);
//     completer.complete();
//     // blockToSend.work = foundWork;
//     // AccountAPI().processRequest(blockToSend, subType);
//     notifyListeners();
//   }
  setWork(String workk) {
    // work = workk;
    completer.complete(workk);
  }

//, required Function callBack
  generateWork({required String hash, int threads = 3}) async {
    String completeURL =
        '$powScriptURL?hash=$hash&threads=${threads.toString()}';
    WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        "Print",
        onMessageReceived: (JavaScriptMessage jsChannel) {
          // print(jsChannel.message);
          setWork(jsChannel.message);
          // controller.runJavaScript('window.stop();');
        },
      )
      ..loadRequest(Uri.parse(completeURL));
    // controller.loadRequest(Uri.parse(completeURL));
    // await completer.future;
    // callBackFn = callBack;
  }

  cancelWork() {
    controller.loadRequest(Uri.parse('about:blank'));
  }

  onConsoleMessage(data) {
    print("onconsolemessage ${data.message}");
  }
}
