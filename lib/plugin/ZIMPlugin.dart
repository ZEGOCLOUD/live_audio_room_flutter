// ignore_for_file: avoid_print

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class ZIMPlugin {
  static const MethodChannel channel = MethodChannel('ZIMPlugin');

  static createZIM(int appID) {
    print('The pid is $appID .');
    channel.invokeMethod("createZIM", {"appID": appID});
  }

  static configEventHandle() {

    const standardMethod = StandardMethodCodec();
    // Register a mock for EventChannel. EventChannel under the hood uses
    // MethodChannel to listen and cancel the created stream.
    // ServicesBinding.instance?.defaultBinaryMessenger
    //     .setMockMessageHandler('eventChannelDemo', (message) async {
    //   // Decode the message into MethodCallHandler.
    //   final methodCall = standardMethod.decodeMethodCall(message);
    //
    //   if (methodCall.method == 'listen') {
    //   } else if (methodCall.method == 'cancel') {
    //   } else {
    //   }
    // });
  }


}