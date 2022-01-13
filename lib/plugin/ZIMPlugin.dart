// ignore_for_file: avoid_print

import 'dart:ffi';

import 'package:flutter/services.dart';
class ZIMPlugin {
  static const MethodChannel channel = MethodChannel('ZIMPlugin');

  static createZIM(int appID) {
    print('The pid is $appID .');
    channel.invokeMethod("createZIM", {"appID": appID});
  }

}