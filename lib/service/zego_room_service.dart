import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_provider_utilities/flutter_provider_utilities.dart';

import 'package:live_audio_room_flutter/plugin/ZIMPlugin.dart';
import 'package:live_audio_room_flutter/service/zego_room_manager.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:live_audio_room_flutter/common/room_info_content.dart';
import 'package:live_audio_room_flutter/constants/zego_constant.dart';

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
typedef RoomLeaveCallback = VoidCallback;
typedef RoomEnterCallback = VoidCallback;

class ZegoRoomService extends ChangeNotifier with MessageNotifierMixin {
  RoomInfo roomInfo = RoomInfo('', '', '');
  RoomLeaveCallback? roomLeaveCallback;
  RoomEnterCallback? roomEnterCallback;

  ZegoRoomService() {
    ZIMPlugin.onRoomInfoUpdate = _onRoomInfoUpdate;
    ZIMPlugin.onRoomStateChanged = _onRoomStateChanged;
  }

  onRoomLeave() {
    roomInfo = RoomInfo('', '', '');
    notifyListeners();
  }

  onRoomEnter() {}

  String get _localUserID {
    return ZegoRoomManager.shared.userService.localUserInfo.userID;
  }

  String get _localUserName {
    return ZegoRoomManager.shared.userService.localUserInfo.userName;
  }

  Future<int> createRoom(String roomID, String roomName, String token) async {
    var result = await ZIMPlugin.createRoom(roomID, roomName, _localUserID, 8);
    var code = result['errorCode'];
    if (code == 0) {
      var result = await ZIMPlugin.queryRoomAllAttributes(roomID);
      var attributesResult = result['roomAttributes'];
      var roomDic = attributesResult['room_info'];
      _updateRoomInfo(RoomInfo.fromJson(jsonDecode(roomDic)));
      _loginRtcRoom();
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
      _loginRtcRoom();
      notifyListeners();
    }
    return code;
  }

  Future<int> leaveRoom() async {
    _logoutRtcRoom();

    var result = await ZIMPlugin.leaveRoom(roomInfo.roomID);
    var code = result['errorCode'];
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

  Future<void> _onRoomStateChanged(int state, int event) async {
    ZimRoomState? roomState = ZimRoomStateExtension.mapValue[state];
    zimRoomEvent? roomEvent = zimRoomEventExtension.mapValue[event];

    print(
        "_onRoomStateChanged state:$state, $roomState, event:$event, $roomEvent");

    if (roomState == ZimRoomState.zimRoomStateDisconnected) {
      if (roomLeaveCallback != null) {
        roomLeaveCallback!();
      }
      if (roomEvent == zimRoomEvent.zimRoomEventEnterFailed) {
        // network error leave room
        RoomInfoContent toastContent = RoomInfoContent.empty();
        toastContent.toastType = RoomInfoType.roomNetworkLeave;
        notifyInfo(json.encode(toastContent.toJson()));
      }
    } else if (roomState == ZimRoomState.zimRoomStateConnected &&
        roomEvent == zimRoomEvent.zimRoomEventSuccess) {
      var result = await ZIMPlugin.queryRoomAllAttributes(roomInfo.roomID);
      var attributesResult = result['roomAttributes'];
      var roomDic = attributesResult['room_info'];
      if (roomDic == null) {
        // room has end
        RoomInfoContent toastContent = RoomInfoContent.empty();
        toastContent.toastType = RoomInfoType.roomEndByHost;
        notifyInfo(json.encode(toastContent.toJson()));
      } else {
        _updateRoomInfo(RoomInfo.fromJson(jsonDecode(roomDic)));
        if (roomEnterCallback != null) {
          roomEnterCallback!();
        }
      }
    }

    notifyListeners();
  }

  void _onRoomInfoUpdate(String roomID, Map<String, dynamic> roomInfoJson) {
    // room has end by host
    if (roomInfoJson.keys.isEmpty) {
      if (_localUserID != roomInfo.hostID) {
        leaveRoom();
      }

      RoomInfoContent toastContent = RoomInfoContent.empty();
      toastContent.toastType = RoomInfoType.roomEndByHost;
      notifyInfo(json.encode(toastContent.toJson()));

      return;
    } else {
      _updateRoomInfo(RoomInfo.fromJson(roomInfoJson));
      if (roomEnterCallback != null) {
        roomEnterCallback!();
      }
      notifyListeners();
    }
  }

  Future<void> _loginRtcRoom() async {
    var user = ZegoUser(_localUserID, _localUserName);
    var config = ZegoRoomConfig.defaultConfig();
    var result = await ZIMPlugin.getRTCToken(roomInfo.roomID, _localUserID);
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

    RoomInfoContent toastContent = RoomInfoContent.empty();
    if (oldRoomInfo.isTextMessageDisable != roomInfo.isTextMessageDisable) {
      toastContent.toastType = RoomInfoType.textMessageDisable;
      toastContent.message = roomInfo.isTextMessageDisable.toString();
    }
    notifyInfo(json.encode(toastContent.toJson()));
  }
}
