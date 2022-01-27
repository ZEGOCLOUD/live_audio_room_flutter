import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:zego_express_engine/zego_express_engine.dart';

import 'package:live_audio_room_flutter/plugin/zim_plugin.dart';
import 'package:live_audio_room_flutter/service/zego_gift_service.dart';
import 'package:live_audio_room_flutter/service/zego_loading_service.dart';
import 'package:live_audio_room_flutter/service/zego_message_service.dart';
import 'package:live_audio_room_flutter/service/zego_room_service.dart';
import 'package:live_audio_room_flutter/service/zego_speaker_seat_service.dart';
import 'package:live_audio_room_flutter/service/zego_user_service.dart';
import 'package:live_audio_room_flutter/constants/zim_error_code.dart';

typedef ZegoRoomCallback = Function(int);

class ZegoRoomManager extends ChangeNotifier {
  static var shared = ZegoRoomManager();

  ZegoRoomService roomService = ZegoRoomService();
  ZegoGiftService giftService = ZegoGiftService();
  ZegoLoadingService loadingService = ZegoLoadingService();
  ZegoMessageService messageService = ZegoMessageService();
  ZegoSpeakerSeatService speakerSeatService = ZegoSpeakerSeatService();
  ZegoUserService userService = ZegoUserService();

  _onRoomLeave() {
    // Reset all service data
    giftService.onRoomLeave();
    loadingService.onRoomLeave();
    messageService.onRoomLeave();
    roomService.onRoomLeave();
    speakerSeatService.onRoomLeave();
    userService.onRoomLeave();
  }

  _onRoomEnter() {
    giftService.onRoomEnter();
    loadingService.onRoomEnter();
    messageService.onRoomEnter();
    roomService.onRoomEnter();
    speakerSeatService.onRoomEnter();
    userService.onRoomEnter();
  }

  Future<void> initWithAPPID(int appID, String appSign, String serverSecret,
      ZegoRoomCallback callback) async {
    await ZIMPlugin.createZIM(appID, appSign, serverSecret);
    ZIMPlugin.registerEventHandler();

    ZegoExpressEngine.onRoomStreamUpdate = _onRoomStreamUpdate;
    ZegoExpressEngine.onApiCalledResult = _onApiCalledResult;
    ZegoEngineProfile profile =
    ZegoEngineProfile(appID, appSign, ZegoScenario.General);
    ZegoExpressEngine.createEngineWithProfile(profile);

    // setup service
    roomService.roomEnterCallback = _onRoomEnter;
    roomService.roomLeaveCallback = _onRoomLeave;
    userService.userOfflineCallback = _onRoomLeave;
    userService.registerMemberJoinCallback(messageService.onRoomMemberJoined);
    userService.registerMemberLeaveCallback(messageService.onRoomMemberLeave);
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

  Future<String> getZimVersion() async {
    var result = await ZIMPlugin.getZIMVersion();
    var errorCode = result['errorCode'];
    if (ZIMErrorCodeExtension.valueMap[zimErrorCode.success] == errorCode) {
      return result["version"].toString();
    }

    return '';
  }

  void _onRoomStreamUpdate(String roomID, ZegoUpdateType updateType,
      List<ZegoStream> streamList, Map<String, dynamic> extendedData) {
    for (final stream in streamList) {
      if (updateType == ZegoUpdateType.Add) {
        ZegoExpressEngine.instance.startPlayingStream(stream.streamID);
      } else {
        ZegoExpressEngine.instance.stopPlayingStream(stream.streamID);
      }
    }
  }

  void _onApiCalledResult(int errorCode, String funcName, String info) {
    if (ZIMErrorCodeExtension.valueMap[zimErrorCode.success] != errorCode) {
      print(
          "_onApiCalledResult funcName:$funcName, errorCode:$errorCode, info:$info");
    }
  }
}
