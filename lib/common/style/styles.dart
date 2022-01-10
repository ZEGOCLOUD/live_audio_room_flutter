import 'package:flutter/material.dart';

/// colors
class StyleColors {
  static const Color dark = Color(0xff1B1B1B);
  static const Color red = Color(0xffEE1515);

  static const Color settingsVersion = Color(0xff989BA8);
  static const Color settingsBackgroundColor = Color(0xffF4F5F6);
  static const Color settingsTitleBackgroundColor = Colors.white;
  static const Color settingsCellBackgroundColor = Colors.white;

  static const Color loginTextHintColor = Color(0xff989BA8);
  static const Color loginTextInputColor = Color(0xff1B1B1B);
  static const Color loginTextBorderColor = Color(0xffF0F0F0);
  static const Color loginButtonColor = Color(0xff0055FF);
}

/// icons
class StyleIconUrls {
  static const String navigator_back = 'images/navigator_back.png';
}

/// constant style
class StyleConstant {
  static const appBarTitleSize = 17.0;
  static const settingsFontSize = 14.0;
  static const loginTitleFontSize = 30.0;

  static const settingAppBar = TextStyle(
    color: Colors.black,
    fontSize: appBarTitleSize,
  );
  static const settingTitle = TextStyle(
    color: StyleColors.dark,
    fontSize: settingsFontSize,
  );
  static const settingVersion = TextStyle(
    color: StyleColors.settingsVersion,
    fontSize: settingsFontSize,
  );
  static const settingLogout = TextStyle(
    color: StyleColors.red,
    fontSize: settingsFontSize,
  );

  static const loginTitle = TextStyle(
    color: Colors.black,
    fontSize: loginTitleFontSize,
  );
}
