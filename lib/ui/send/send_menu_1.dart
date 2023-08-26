// import 'dart:async';

import 'package:flutter/material.dart';

class SendMenu1 extends StatefulWidget {
  const SendMenu1({super.key});

  @override
  _SendMenu1 createState() => _SendMenu1();
}

class _SendMenu1 extends State<SendMenu1> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    // return Container(child: buildMainSettings(context));
    return SafeArea(
      minimum:
          EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035),
      child: Column(children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            //Empty SizedBox
            const SizedBox(
              width: 60,
              height: 60,
            ),

            // Container for the header, address and balance text
            Column(
              children: <Widget>[
                // Sheet handle
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  height: 5,
                  width: MediaQuery.of(context).size.width * 0.15,
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 15.0),
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 140),
                  child: const Column(
                    children: <Widget>[
                      // Header
                      Text("test"),
                    ],
                  ),
                ),
              ],
            ),
            //Empty SizedBox
            const SizedBox(
              width: 60,
              height: 60,
            ),
            Container(
              margin: const EdgeInsets.only(top: 10.0, left: 30, right: 30),
              child: Container(
                  child: TextButton(
                style: TextButton.styleFrom(
                    foregroundColor: Colors.green,
                    backgroundColor: Colors.grey.shade700 // foreground
                    ),
                onPressed: () {
                  // showModal(context, "meow");
                  Navigator.of(context).pop(context);
                },
                child: const SizedBox(
                  child: Text(
                    "X",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
              )),
            ),
          ],
        ),
      ]),
    );
  }

  // Widget buildMainSettings(BuildContext context) {}
}
