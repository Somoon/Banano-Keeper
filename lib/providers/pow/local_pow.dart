// import 'package:bananokeeper/providers/get_it_main.dart';
// import 'package:bananokeeper/providers/user_data.dart';
import 'dart:async';

// import 'package:bananokeeper/api/account_api.dart';
// import 'package:bananokeeper/api/state_block.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/user_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
// Import for Android features.
// import 'package:webview_flutter_android/webview_flutter_android.dart';
// // Import for iOS features.
// import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class LocalPoW {
  Completer<String> completer = Completer<String>();
  late WebViewController controller = WebViewController();

  //maybe have multi/different hosts in case one is down (gh?)
  String powScriptURL = 'https://moonano.net/assets/data/pow/multiThread.html';

  setWork(String work) {
    completer.complete(work);
  }

  generateWork({required String hash}) async {
    int threads = services<UserData>().getThreadCount();
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
  }

  cancelWork() {
    controller.loadRequest(Uri.parse('about:blank'));
  }

  onConsoleMessage(data) {
    print("onconsolemessage ${data.message}");
  }
}
