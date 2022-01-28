import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class SecretReader {
  int _appID = 0;
  String _appSign = "";
  String _serverSecret = "";

  static SecretReader? _instance;

  int get appID {
    return _appID;
  }

  String get appSign {
    return _appSign;
  }

  String get serverSecret {
    return _serverSecret;
  }

  Future<void> loadKeyCenterData() async {
    var jsonStr = await rootBundle.loadString("assets/key_center.json");
    var dataObj = jsonDecode(jsonStr);
    _appID = dataObj['appID'];
    _appSign = dataObj['appSign'];
    _serverSecret = dataObj['serverSecret'];
  }

  SecretReader._internal();

  factory SecretReader() => _getInstance();

  static SecretReader get instance => _getInstance();

  static _getInstance() {
    // 只能有一个实例
    _instance ??= SecretReader._internal();
    return _instance;
  }
}
