/*
// import 'package:bananokeeper/providers/get_it_main.dart';
// import 'package:bananokeeper/providers/user_data.dart';
import 'dart:async';

// import 'package:bananokeeper/api/account_api.dart';
// import 'package:bananokeeper/api/state_block.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/user_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:webview_flutter/webview_flutter.dart';
// Import for Android features.
// import 'package:webview_flutter_android/webview_flutter_android.dart';
// // Import for iOS features.
// import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class LocalPoW {
  final InAppLocalhostServer localhostServer = InAppLocalhostServer();
  Completer<String> completer = Completer<String>();
  late WebViewController controller = WebViewController();

  //maybe have multi/different hosts in case one is down (gh?)
  // String powScriptURL = 'https://moonano.net/assets/data/pow/multiThread.html';
  String powScriptURL = "pow/multiThread.html";

  setWork(String work) {
    completer.complete(work);
  }

  generateWork({required String hash}) async {
    await localhostServer.start();
    int threads = services<UserData>().getThreadCount();
    String completeURL = powScriptURL;
    // '$powScriptURL?hash=$hash&threads=${threads.toString()}';
    print(completeURL);
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
//       ..runJavaScriptReturningResult("""
//       var hash = '$hash';
// var threads = 2;
//         var start = 0;
//         var NUM_THREADS = 3;
//         if(threads != false) NUM_THREADS = threads;
//         // var hash = "BD9F737DDECB0A34DFBA0EDF7017ACB0EF0AA04A6F7A73A406191EF80BB290AD";
//         var workers = pow_initiate(NUM_THREADS, '');
//         pow_callback(workers, hash, function(){
//             start = Date.now();
//             // console.log("Started");
//         }, function(data){
//             // console.log('Done');
//             var end = Date.now();
//             var time = (end - start) / 1000;
//             console.log("Time spent " + time);
//             // console.log(data)
//             Print.postMessage(data);
//             window.stop();
//             //console.log('stopp');
//         });
//
//         function hex_uint8(hex) {
//         	var length = (hex.length / 2) | 0;
//         	var uint8 = new Uint8Array(length);
//         	for (let i = 0; i < length; i++) uint8[i] = parseInt(hex.substr(i * 2, 2), 16);
//         	return uint8;
//         }
//         """)
//       ..loadFlutterAsset(completeURL);
//     controller.runJavaScript(
//       "hash = '${hash}'; threads = $threads; test();",
//     );
      ..loadRequest(Uri.parse(
          'http://localhost:8080/${powScriptURL}?hash=$hash&threads=${threads.toString()}'));
    //(Uri(scheme: 'file', path: file.path).toString());
  }

  cancelWork() {
    controller.loadRequest(Uri.parse('about:blank'));
  }

  onConsoleMessage(data) {
    print("onconsolemessage ${data.message}");
  }
}

 */
