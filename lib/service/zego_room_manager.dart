import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:async/async.dart';
import 'package:live_audio_room_flutter/plugin/ZIMPlugin.dart';
import 'package:live_audio_room_flutter/service/zego_gift_service.dart';
import 'package:live_audio_room_flutter/service/zego_message_service.dart';
import 'package:live_audio_room_flutter/service/zego_room_service.dart';
import 'package:live_audio_room_flutter/service/zego_speaker_seat_service.dart';
import 'package:live_audio_room_flutter/service/zego_user_service.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

typedef ZegoRoomCallback = Function(int);

class ZegoRoomManager extends ChangeNotifier {

  static var shared = ZegoRoomManager();

  // MARK: - Public
  /// The room information management instance, contains the room information, room status and other business logics.
  ZegoRoomService roomService = ZegoRoomService();
  /// The user information management instance, contains the in-room user information management, logged-in user information and other business logics.
  ZegoUserService userService = ZegoUserService();
  /// The room speaker seat management instance, contains the speaker seat management logic.
  ZegoSpeakerSeatService speakerService = ZegoSpeakerSeatService();
  /// The message management instance, contains the IM messages management logic.
  ZegoMessageService messageService = ZegoMessageService();
  /// The gift management instance, contains the gift sending and receiving logics.
  ZegoGiftService giftService = ZegoGiftService();

  void initWithAPPID(int appID, String appSign, ZegoRoomCallback callback) {
    ZIMPlugin.createZIM(appID);
    ZIMPlugin.registerEventHandler();

    // Create ZegoExpressEngine (Init SDK)
    ZegoEngineProfile profile = ZegoEngineProfile(appID, appSign, ZegoScenario.General);
    ZegoExpressEngine.createEngineWithProfile(profile);

    callback(0);
  }

  Future<int> uninit() async {
    logoutRtcRoom();
    var result = await ZIMPlugin.destoryZIM();
    ZegoExpressEngine.destroyEngine();
    ZIMPlugin.unregisterEventHandler();
    return result['errorCode'];
  }

  Future<int> uploadLog(ZegoRoomCallback callback) async {
    var result = await ZIMPlugin.uploadLog();
    return result['errorCode'];
  }

  void logoutRtcRoom() {
    ZegoExpressEngine.instance.logoutRoom("123");
    userService.userList = [];
    roomService = ZegoRoomService();
    speakerService = ZegoSpeakerSeatService();
    messageService = ZegoMessageService();
    giftService = ZegoGiftService();
  }

}
