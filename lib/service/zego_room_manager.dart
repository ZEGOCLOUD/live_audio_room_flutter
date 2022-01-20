import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:live_audio_room_flutter/plugin/ZIMPlugin.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

typedef ZegoRoomCallback = Function(int);

class ZegoRoomManager extends ChangeNotifier {

  static var shared = ZegoRoomManager();

  void initWithAPPID(int appID, String appSign, String serverSecret, ZegoRoomCallback callback) {
    ZIMPlugin.createZIM(appID, appSign, serverSecret);
    ZIMPlugin.registerEventHandler();

    ZegoEngineProfile profile = ZegoEngineProfile(appID, appSign, ZegoScenario.General);
    ZegoExpressEngine.createEngineWithProfile(profile);

    callback(0);
  }

  Future<int> uninit() async {
    logoutRtcRoom();
    var result = await ZIMPlugin.destroyZIM();
    ZegoExpressEngine.destroyEngine();
    ZIMPlugin.unregisterEventHandler();
    return result['errorCode'];
  }

  Future<int> uploadLog() async {
    var result = await ZIMPlugin.uploadLog();
    return result['errorCode'];
  }

  void logoutRtcRoom() {
    ZegoExpressEngine.instance.logoutRoom("123");
  }

}
