// ignore_for_file: avoid_print

import 'package:flutter/services.dart';
class ZIMPlugin {
  static const MethodChannel channel = MethodChannel('ZIMPlugin');

  static createZIM(String pid) {
    print('The pid is $pid .');
    channel.invokeMethod("createZIM", {"pid": pid});
  }

}