import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_provider_utilities/flutter_provider_utilities.dart';

import 'package:live_audio_room_flutter/plugin/ZIMPlugin.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:live_audio_room_flutter/common/toast_content.dart';

class RoomInfo {
  String roomID = "";
  String roomName = "";
  String hostID = "";
  int seatNum = 0;
  bool isTextMessageDisable = false;
  bool isSeatClosed = false;

  RoomInfo(this.roomID, this.roomName, this.hostID);

  RoomInfo clone() {
    var cloneObject = RoomInfo(roomID, roomName, hostID);
    cloneObject.seatNum = seatNum;
    cloneObject.isTextMessageDisable = isTextMessageDisable;
    cloneObject.isSeatClosed = isSeatClosed;
    return cloneObject;
  }

  RoomInfo.fromJson(Map<String, dynamic> json)
      : roomID = json['id'],
        roomName = json['name'],
        hostID = json['host_id'],
        seatNum = json['num'],
        isTextMessageDisable = json['disable'],
        isSeatClosed = json['close'];

  Map<String, dynamic> toJson() => {
        'id': roomID,
        'name': roomName,
        'host_id': hostID,
        'num': seatNum,
        'disable': isTextMessageDisable,
        'close': isSeatClosed
      };
}

enum RoomState {
  disconnected,
  connecting,
  connected,
}

typedef RoomCallback = Function(int);

class ZegoRoomService extends ChangeNotifier with MessageNotifierMixin {
  RoomInfo roomInfo = RoomInfo('', '', '');
  String localUserID = ""; // Update while user service data is updated.
  String localUserName = ""; // Update while user service data is updated.

  ZegoRoomService() {
    ZIMPlugin.onRoomStatusUpdate = _onRoomStatusUpdate;
  }

  Future<int> createRoom(String roomID, String roomName, String token) async {
    var result = await ZIMPlugin.createRoom(roomID, roomName, localUserID, 8);
    var code = result['errorCode'];
    if (code == 0) {
      var result = await ZIMPlugin.queryRoomAllAttributes(roomID);
      var attributesResult = result['roomAttributes'];
      var roomDic = attributesResult['room_info'];
      _updateRoomInfo(RoomInfo.fromJson(jsonDecode(roomDic)));
      notifyListeners();
    }
    return code;
  }

  Future<int> joinRoom(String roomID, String token) async {
    var joinResult = await ZIMPlugin.joinRoom(roomID);
    var code = joinResult['errorCode'];
    if (code == 0) {
      var result = await ZIMPlugin.queryRoomAllAttributes(roomID);
      var attributesResult = result['roomAttributes'];
      var roomDic = attributesResult['room_info'];
      _updateRoomInfo(RoomInfo.fromJson(jsonDecode(roomDic)));
      notifyListeners();
    }
    return code;
  }

  Future<int> leaveRoom() async {
    var result = await ZIMPlugin.leaveRoom(roomInfo.roomID);
    var code = result['errorCode'];
    if (code == 0) {
      roomInfo = RoomInfo('', '', '');
      notifyListeners();
    }
    return code;
  }

  Future<int> disableTextMessage(bool disable) async {
    var targetRoomInfo = roomInfo.clone();
    targetRoomInfo.isTextMessageDisable = disable;
    _updateRoomInfo(targetRoomInfo);

    var json = jsonEncode(roomInfo);
    var map = {'room_info': json};
    var mapJson = jsonEncode(map);
    var result =
        await ZIMPlugin.setRoomAttributes(roomInfo.roomID, mapJson, true);
    int code = result['errorCode'];
    if (code != 0) {
      //  restore value
      var targetRoomInfo = roomInfo.clone();
      targetRoomInfo.isTextMessageDisable = !disable;
      _updateRoomInfo(targetRoomInfo);
    }

    notifyListeners();
    return code;
  }

  void _onRoomStatusUpdate(String roomID, Map<String, dynamic> roomInfoJson) {
    _updateRoomInfo(RoomInfo.fromJson(roomInfoJson));
    notifyListeners();
  }

  Future<void> _loginRtcRoom() async {
    if (roomInfo.roomID == null || localUserID == null) {
      return;
    }
    var user = ZegoUser(localUserID, localUserName);
    var config = ZegoRoomConfig.defaultConfig();
    var result = await ZIMPlugin.getRTCToken(roomInfo.roomID, localUserID);
    config.token = result["token"];
    config.maxMemberCount = 0;
    ZegoExpressEngine.instance.loginRoom(roomInfo.roomID, user, config: config);
    var soundConfig = ZegoSoundLevelConfig(1000, false);
    ZegoExpressEngine.instance.startSoundLevelMonitor(config: soundConfig);
  }

  void _logoutRtcRoom() {
    ZegoExpressEngine.instance.logoutRoom(roomInfo.roomID);
  }

  void _updateRoomInfo(RoomInfo updatedRoomInfo) {
    var oldRoomInfo = roomInfo.clone();
    roomInfo = updatedRoomInfo.clone();
    RoomToastContent toastContent = RoomToastContent.empty();
    if (oldRoomInfo.isTextMessageDisable != roomInfo.isTextMessageDisable) {
      toastContent.toastType = RoomToastType.textMessageDisable;
      toastContent.message = roomInfo.isTextMessageDisable.toString();
    }
    notifyInfo(json.encode(toastContent.toJson()));
  }
}
