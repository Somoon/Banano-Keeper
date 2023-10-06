import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

class MessageSignPage extends StatefulWidget with GetItStatefulWidgetMixin {
  // ManagementPage({super.key});

  @override
  MSPState createState() => MSPState();

  // final Widget pageContent;
  // final String pageTitle;
  MessageSignPage({super.key});
  // MessageSignPage(this.pageContent, this.pageTitle, {super.key});
}

class MSPState extends State<MessageSignPage> with GetItStateMixin {
  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      // animationController: _animationController,
      onClosing: () => Navigator.pop(context),
      builder: (context) => const Text("a"),
    );
  }

// @override Route<T>
// createRoute(BuildContext context) => DialogRoute<T>(
//   context: context, settings: this,
//   builder: (context) => Dialog( child child, ), );
}

Widget aaTest(BuildContext context) {
  return Text("aaaa");
}

/*
class ModalBuilder<T> {
  Route<T> modalSheetBuilder(BuildContext context, Widget child) {
    //, CustomPage<T> page) {
    return ModalBottomSheetRoute(
      // settings: page,
      builder: (context) {
        return Text("aaa");
      },
      isScrollControlled: true,
    );
  }
}

 */
