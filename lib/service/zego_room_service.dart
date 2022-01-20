import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:live_audio_room_flutter/plugin/ZIMPlugin.dart';

class RoomInfo {
  String roomID = "";
  String roomName = "";
  String hostID = "";
  int seatNum = 0;
  bool isTextMessageDisable = false;
  bool isSeatClosed = false;

  RoomInfo(this.roomID, this.roomName, this.hostID);

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

class ZegoRoomService extends ChangeNotifier {
  RoomInfo roomInfo = RoomInfo('', '', '');
  String localHostID = ""; // Update while user service data is updated.

  ZegoRoomService() {
    ZIMPlugin.onRoomStatusUpdate = onRoomStatusUpdate;
  }

  Future<int> createRoom(String roomID, String roomName, String token) async {
    var result = await ZIMPlugin.createRoom(roomID, roomName, localHostID, 8);
    var code = result['errorCode'];
    if (code == 0) {
      var attributesResult = await ZIMPlugin.queryRoomAllAttributes(roomID);
      var roomDic = attributesResult['room_info'];
      roomInfo = RoomInfo.fromJson(jsonDecode(roomDic));
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
      roomInfo = RoomInfo.fromJson(jsonDecode(roomDic));
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
    roomInfo.isTextMessageDisable = disable;
    var json = jsonEncode(roomInfo);
    var map = {'room_info': json};
    var mapJson = jsonEncode(map);

    var result =
        await ZIMPlugin.setRoomAttributes(roomInfo.roomID, mapJson, true);
    int code = result['errorCode'];
    if (code == 0) {
      roomInfo.isTextMessageDisable = disable;
    } else {
      roomInfo.isTextMessageDisable = !disable;
    }
    notifyListeners();
    return code;
  }

  void onRoomStatusUpdate(String roomID, Map<String, dynamic> roomInfoJson) {
    roomInfo = new RoomInfo.fromJson(roomInfoJson);
    notifyListeners();
  }
}
