import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:live_audio_room_flutter/plugin/ZIMPlugin.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

typedef ZegoRoomCallback = Function(int);

class ZegoRoomManager extends ChangeNotifier {

  static var shared = ZegoRoomManager();

  Future<void> initWithAPPID(int appID, String appSign, String serverSecret, ZegoRoomCallback callback) async {
    var result = await ZIMPlugin.createZIM(appID, appSign, serverSecret);
    ZIMPlugin.registerEventHandler();

    ZegoExpressEngine.onApiCalledResult = _onApiCalledResult;
    ZegoEngineProfile profile = ZegoEngineProfile(appID, appSign, ZegoScenario.General);
    ZegoExpressEngine.createEngineWithProfile(profile);
    ZegoExpressEngine.onRoomStreamUpdate = _onRoomStreamUpdate;
  }

  void _onApiCalledResult(int errorCode, String funcName, String info) {
    print("========= $errorCode $funcName");
  }

  Future<int> uninit() async {
    var result = await ZIMPlugin.destroyZIM();
    ZegoExpressEngine.destroyEngine();
    ZIMPlugin.unregisterEventHandler();
    return result['errorCode'];
  }

  Future<int> uploadLog() async {
    var result = await ZIMPlugin.uploadLog();
    return result['errorCode'];
  }

  void _onRoomStreamUpdate(String roomID, ZegoUpdateType updateType, List<ZegoStream> streamList, Map<String, dynamic> extendedData) {
    for (final stream in streamList) {
      if (updateType == ZegoUpdateType.Add) {
        ZegoExpressEngine.instance.startPlayingStream(stream.streamID);
      } else {
        ZegoExpressEngine.instance.stopPlayingStream(stream.streamID);
      }
    }
  }

}
