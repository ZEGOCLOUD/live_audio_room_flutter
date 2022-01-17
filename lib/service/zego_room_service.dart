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

  RoomInfo.formJson(Map<String, dynamic> json)
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
        'isSeatClosed': isSeatClosed
      };
}

typedef RoomCallback = Function(int);

class ZegoRoomService extends ChangeNotifier {
  RoomInfo roomInfo = RoomInfo('', '', '');
  String localHostID = ""; // Update while user service data is updated.

  ZegoRoomService() {
    // TODO@larry binding delegate to SDK and call notifyListeners() while data changed.
  }

  Future<int> createRoom(String roomId, String roomName, String token) async {
    var result = await ZIMPlugin.createRoom(roomId, roomName);
    var code = result['errorCode'];
    if (code == 0) {
      roomInfo = RoomInfo(roomId, roomName, localHostID);
      notifyListeners();
    }
    return code;
  }

  Future<int> joinRoom(String roomId, String token) async {
    var result = await ZIMPlugin.joinRoom(roomId);
    int code = result['errorCode'];
    if (code == 0) {
      var roomDic = result['roomInfo'];
      roomInfo = RoomInfo.formJson(jsonDecode(roomDic));
      notifyListeners();
    }
    return code;
  }

  Future<int> leaveRoom() async {
    var result = await ZIMPlugin.leaveRoom(roomInfo.roomID);
    return result['errorCode'];
  }

  Future<int> disableTextMessage(bool disable) async {
    var json = jsonEncode(roomInfo);
    var map = {'room_info': json};
    var mapJson = jsonEncode(map);

    var result =
        await ZIMPlugin.setRoomAttributes(roomInfo.roomID, mapJson, true);
    int code = result['errorCode'];
    if (code == 0) {
      roomInfo.isTextMessageDisable = disable;
      notifyListeners();
    }
    return code;
  }
}
