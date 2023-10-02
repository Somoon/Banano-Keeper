// ignore_for_file: unnecessary_getters_setters

import 'package:flutter/material.dart';

class ThemeModel extends ChangeNotifier {
  BaseTheme curTheme = YellowTheme();
  String activeTheme = "Yellow";
  void setTheme(themeName) {
    activeTheme = themeName;
    switch (themeName) {
      case "Second":
        curTheme = SecondTheme();
      case "Dark":
        curTheme = DarkTheme();
      case "Slate":
        curTheme = SlateTheme();
      case "Yellow":
      default:
        curTheme = YellowTheme();
        activeTheme = "Yellow";
    }
    curTheme.textStyle = TextStyle(
      color: curTheme.text,
      fontSize: curTheme.fontSize,
    );
    notifyListeners();
  }
}

abstract class BaseTheme {
  late Color primary;
  late Color primaryAppBar;
  late Color primaryBottomBar;
  late Color secondary;
  late Color sideDrawerColor;
  late Color text;
  late Color textSecondary;
  late Color textDisabled;
  late Color offColor;
  late Color buttonOutline;
  double fontSize = 18;
  late TextStyle textStyle = TextStyle(
    color: text,
    fontSize: fontSize,
  );
  Color red = Colors.red;
  Color green = Colors.green;
  Color blue = Colors.blue;
  Color lightgreen = const Color(0xFF7BC043);
  late Color buttonIconColor;
  late ButtonStyle btnStyle = ButtonStyle(
    overlayColor:
        MaterialStateColor.resolveWith((states) => text.withOpacity(0.3)),
    // backgroundColor: MaterialStatePropertyAll<Color>(Colors.green),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    ),

    side: MaterialStatePropertyAll<BorderSide>(
      BorderSide(
        color: buttonOutline,
        width: 1,
      ),
    ),
  );
  late ButtonStyle btnStyleNoBorder = ButtonStyle(
    overlayColor:
        MaterialStateColor.resolveWith((states) => text.withOpacity(0.3)),
    // backgroundColor: MaterialStatePropertyAll<Color>(Colors.green),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    ),
  );
  late ButtonStyle btnStyleRect = ButtonStyle(
    overlayColor:
        MaterialStateColor.resolveWith((states) => text.withOpacity(0.3)),
    // backgroundColor: MaterialStatePropertyAll<Color>(Colors.green),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
      ),
    ),
    // backgroundColor: MaterialStatePropertyAll<Color>(Colors.green),
  );
}

class YellowTheme extends BaseTheme {
  static const yellow = Color(0xFFA6950E);

  // static const green = Color(0xFF4CBF4B);
  static const white = Color(0xFFFFFFFF);
  static const offwhite = Color(0xFFA9A9A9);

  Color buttonIconColor = white;
  Color offColor = offwhite;
  Color primaryAppBar = Color(0xFF333741);
  Color primaryBottomBar = Color(0xFF333741);
  Color primary = const Color(0xFF232629);
  Color secondary = const Color(0xFF424651);

  Color sideDrawerColor = const Color(0xFF424651);
  Color text = const Color(0xffeeba2c);
  Color textSecondary = Colors.white;
  Color textDisabled = offwhite;
  Color buttonOutline = white;
}

class DarkTheme extends BaseTheme {
  static const yellow = Color(0xFFA6950E);

  // static const green = Color(0xFF4CBF4B);
  static const white = Color(0xFFFFFFFF);
  static const offwhite = Color(0xFFA9A9A9);
  static const black = Color(0xFF000000);
  static const offblack = Color(0xD2343333);

  Color buttonIconColor = white;

  Color offColor = const Color(0xFFA9A9A9);

  Color primaryAppBar = Color(0xFF333741);
  Color primaryBottomBar = Color(0xFF333741);
  Color primary = const Color(0xFF232629);
  Color secondary = const Color(0xFF424651);

  Color sideDrawerColor = const Color(0xFF424651);
  Color text = white;
  Color textSecondary = Colors.blue;

  Color textDisabled = offwhite;
  Color buttonOutline = white;
}

class SecondTheme extends BaseTheme {
  static const darkblue = Color(0xFF2B3985);
  static const black = Color(0xFF000000);
  static const offblack = Color(0xD2343333);

  Color buttonIconColor = darkblue;
  Color primary = const Color(0xFF652139);
  Color primaryAppBar = Color(0xFF333741);
  Color primaryBottomBar = Color(0xFF333741);
  Color secondary = const Color(0xFFAD3962);
  Color sideDrawerColor = darkblue;
  Color text = black;
  Color textSecondary = Colors.lightGreenAccent;

  Color textDisabled = Color(0xD2807D7D);
  Color offColor = const Color(0xFFA9A9A9);
  Color buttonOutline = darkblue;
}

class SlateTheme extends BaseTheme {
  static const black = Color(0xFF000000);

  Color buttonIconColor = black;
  Color primary = const Color(0xFF7a9e9f);
  Color primaryAppBar = Color(0xFF333741);
  Color primaryBottomBar = Color(0xFF333741);
  Color secondary = const Color(0xFFb8d8d8);
  Color sideDrawerColor = const Color(0xFF7a9e9f);
  Color text = const Color(0xFF4f6367);
  Color textSecondary = const Color(0x9A8B42FF);

  Color textDisabled = const Color(0xFFFFFFFF);
  Color offColor = const Color(0xFFeef5db);
  Color buttonOutline = const Color.fromARGB(210, 196, 206, 94);
}
/*
class ThemeModel extends ChangeNotifier {
  //themeList =  [ 1,2,3,4,5]

  ThemeModel([themeModel = "YellowTheme"]) {
    setTheme("YellowTheme");
  }
  String activeTheme = "";

  void setTheme(themeName) {
    // ignore: prefer_typing_uninitialized_variables
    var tt;
    //if theme exist and activeTheme != themeName
    //switch? to use classes directly
    activeTheme = themeName;

    switch (themeName) {
      case "Yellow":
        tt = YellowTheme();
      case "Second":
        tt = SecondTheme();
      default:
        activeTheme =
            themeName; //only set it to def theme if its somewhat non-existent

        tt = YellowTheme();
    }

    //end of switch

    primaryColor = tt.primaryColor;
    secondaryColor = tt.secondaryColor;
    background = tt.background;
    backgroundSecondary = tt.backgroundSecondary;
    text = tt.text;
    textSecondary = tt.textSecondary;

    receive = tt.receive;
    send = tt.send;
    brightness = tt.brightness;
    font = tt.font;
    sideDrawerColor = tt.sideDrawerColor;

    theme = ThemeData(
      // Define the default brightness and colors.
      brightness: (brightness == "dark" ? Brightness.dark : Brightness.light),
      // primary bg color
      primaryColor: primaryColor,

      // Define the default font family.
      fontFamily: font,

      // Define the default `TextTheme`. Use this to specify the default
      // text styling for headlines, titles, bodies of text, and more.
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontSize: 36, fontStyle: FontStyle.italic),
        bodyMedium: TextStyle(fontSize: 14, fontFamily: 'Hind'),
      ),
    );
    //endof if

    notifyListeners();
  }

  ThemeData getTheme() {
    return theme;
  }

  late ThemeData theme;

// abstract class ThemeModel {
  late Color primaryColor;
  late Color secondaryColor;

  late Color background;
  late Color backgroundSecondary;

  late Color text;
  late Color textSecondary;

  late Color receive;
  late Color send;
  late Color sideDrawerColor;

  //theme brightness
  late String _brightness;
  set brightness(String value) {
    _brightness = value;
  }

  String get brightness => _brightness;

  //font used
  late String _font;
  set font(String value) {
    _font = value;
  }

  String get font => _font;
}

// extends ThemeModel
class YellowTheme {
// class YellowTheme {
// #4d4e51
// nice blue bg 0xFF6D8CD0
  Color primaryColor = const Color(0xFF4d4e51);
  Color secondaryColor = const Color(0xFFFB11EF);

  Color background = const Color(0xFF15150E);
  Color backgroundSecondary = const Color(0xFF4B483D);

  Color text = const Color(0xFFFFFFFF);
  Color textSecondary = const Color(0xFF80600F);

  Color receive = const Color(0xFF66C757);
  Color send = const Color(0xFF6C1B1B);
  Color sideDrawerColor = const Color(0xFFF8D067);

  String brightness = "dark";

  String font = "Georgia";
}

class SecondTheme {
// class YellowTheme {
// #4d4e51
// nice blue bg 0xFF6D8CD0
  Color primaryColor = const Color(0xFFFB11EF);
  Color secondaryColor = const Color(0xFFFB11EF);

  Color background = const Color(0xFF15150E);
  Color backgroundSecondary = const Color(0xFF4B483D);

  Color text = const Color(0xFFFFFFFF);
  Color textSecondary = const Color(0xFF80600F);

  Color receive = const Color(0xFF66C757);
  Color send = const Color(0xFF6C1B1B);
  Color sideDrawerColor = const Color(0xFF2E54B4);

  String brightness = "dark";

  String font = "Georgia";
}
*/
/*
class ThemeViewModel extends ChangeNotifier {
  final darkTheme = ThemeData(...;

  final lightTheme = ThemeData(...);

  ThemeData? _themeData;

  ThemeData getTheme() => _themeData ?? lightTheme;

  ThemeViewModel() {
    StorageManager.readData('themeMode').then((value) {
      var themeMode = value ?? 'light';
      if (themeMode == 'light') {
        _themeData = lightTheme;
      } else {
        _themeData = darkTheme;
      }
      notifyListeners();
    });
  }
...
}
 */
