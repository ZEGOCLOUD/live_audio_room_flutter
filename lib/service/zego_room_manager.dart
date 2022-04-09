import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:live_audio_room_flutter/service/zego_token_manager.dart';
import 'dart:async';

import 'package:zego_express_engine/zego_express_engine.dart';

import '../../plugin/zim_plugin.dart';
import '../../service/zego_gift_service.dart';
import '../../service/zego_loading_service.dart';
import '../../service/zego_message_service.dart';
import '../../service/zego_room_service.dart';
import '../../service/zego_speaker_seat_service.dart';
import '../../service/zego_user_service.dart';
import '../../constants/zim_error_code.dart';

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

  Future<void> initWithAPPID(
      int appID, String serverSecret, ZegoRoomCallback callback) async {
    await ZIMPlugin.createZIM(appID, serverSecret);
    ZIMPlugin.registerEventHandler();

    ZegoExpressEngine.onRoomStreamUpdate = _onRoomStreamUpdate;
    ZegoExpressEngine.onApiCalledResult = _onApiCalledResult;

    ZegoExpressEngine.onRoomTokenWillExpire = onRoomTokenWillExpire;
    ZIMPlugin.onTokenWillExpire = onTokenWillExpire;

    ZegoEngineProfile profile = ZegoEngineProfile(appID, ZegoScenario.General);
    ZegoExpressEngine.createEngineWithProfile(profile).then((value) {
      ZegoExpressEngine.instance.enableCamera(false); // demo is pure audio
    });

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

  /// Callback notification that Token authentication is about to expire.
  ///
  /// Description:The callback notification that the Token authentication is about to expire, please use [renewToken] to update the Token authentication.
  ///
  /// @param remainTimeInSecond The remaining time before the token expires.
  /// @param roomID Room ID where the user is logged in, a string of up to 128 bytes in length.
  void onRoomTokenWillExpire(String roomID, int remainTimeInSecond) async {
    log('[token] onRoomTokenWillExpire, $roomID, $remainTimeInSecond');

    var result = await ZegoTokenManager.shared
        .getToken(userService.localUserInfo.userID);
    if (result.isSuccess) {
      var token = result.success;
      renewToken(token, roomService.roomInfo.roomID);
    }
  }

  void onTokenWillExpire(int second) async {
    log('[token] onTokenWillExpire, $second');

    var result = await ZegoTokenManager.shared
        .getToken(userService.localUserInfo.userID);
    if (result.isSuccess) {
      var token = result.success;
      renewToken(token, roomService.roomInfo.roomID);
    }
  }

  /// Renew token.
  ///
  /// Description: After the developer receives [onRoomTokenWillExpire], they can use this API to update the token to ensure that the subsequent RTC&ZIM functions are normal.
  ///
  /// @param token The token that needs to be renew.
  /// @param roomID Room ID.
  void renewToken(String token, String roomID) async {
    ZegoExpressEngine.instance.renewToken(roomID, token);
    ZIMPlugin.renewToken(token);
  }
}
