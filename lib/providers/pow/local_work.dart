import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/user_data.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class LocalWork extends ChangeNotifier {
  // Completer<String> completer = Completer<String>();
  CancelableCompleter<String> completer = CancelableCompleter<String>();
  InAppLocalhostServer localhostServer =
      InAppLocalhostServer(documentRoot: 'assets/pow');
  late HeadlessInAppWebView headlessWebView;
  String url = "http://localhost:8080/multiThread.html";

  LocalWork() {
    // init();
  }

  init() async {
    await localhostServer.start();
    await setupHeadless();
    // print('ok server running');
  }

  setupHeadless() async {
    headlessWebView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(url)),
      /*
      initialSettings: InAppWebViewSettings(
        isInspectable: kDebugMode,
      ),
      */
      onWebViewCreated: (controller) {
        controller.addJavaScriptHandler(
          handlerName: 'Print',
          callback: (args) {
            var work = args[0];
            setWork(work);
            if (kDebugMode) {
              print("found $work");
            }
          },
        );
      },
      /*
      onConsoleMessage: (controller, consoleMessage) {
        if (consoleMessage.message.split(" ")[1] == 'found') {
          print(consoleMessage.message.split(" ")[0]);
        } else {
          if (kDebugMode) {
            print(consoleMessage);
          }
        }
      },
      */
    );

    //load once and keep page open in background
    await headlessWebView.run();
  }

  setWork(String work) {
    if (completer.isCanceled) {
      completer.complete("");
    } else {
      completer.complete(work);
    }
  }

  cancelWork() {
    completer.operation.cancel();
    print('canceled work');
  }

  generateWork({required String hash}) async {
    int threads = services<UserData>().getThreadCount();
    if (headlessWebView.isRunning()) {
      await headlessWebView.webViewController?.evaluateJavascript(
        source: "hash = '$hash'; threads=$threads;",
      );
    }
  }

  // cancelWork() {
  //   headlessWebView.webViewController?.evaluateJavascript(
  //   source: "pow_terminate(workers)",
  //   );
  // }

  disposelocalServer() {
    headlessWebView.dispose();
    localhostServer.close();
  }
}
