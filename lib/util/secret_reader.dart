import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class SecretReader {
  late final int appID;
  late final String appSign;
  late final String serverSecret;

  static SecretReader? _instance;

  SecretReader._internal() {
    rootBundle.loadString("assets/key_center.json").then((jsonStr) {
      var dataObj = jsonDecode(jsonStr);
      appID = dataObj['appID'];
      appSign = dataObj['appSign'];
      serverSecret = dataObj['serverSecret'];
    });
  }

  factory SecretReader() => _getInstance();

  static SecretReader get instance => _getInstance();

  static _getInstance() {
    // 只能有一个实例
    _instance ??= SecretReader._internal();
    return _instance;
  }
}
