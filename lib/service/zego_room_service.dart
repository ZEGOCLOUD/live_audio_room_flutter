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

  void createRoom(String roomId, String roomName, RoomCallback? callback) {
    int code = ZIMPlugin.createRoom(roomId, roomName);
    if (code == 0) {
      roomInfo = RoomInfo(roomId, roomName, localHostID);
    }
    if (callback != null) {
      callback(0);
    }
    notifyListeners();
  }

  void joinRoom(String roomId, RoomCallback? callback) {
    String result = ZIMPlugin.joinRoom(roomId);
    // TODO@oliver call in SDK async callback
    roomInfo = RoomInfo.formJson(jsonDecode(result));
    if (callback != null) {
      callback(roomInfo.roomID.isEmpty ? -1 : 0);
    }
    notifyListeners();
  }

  void leaveRoom(RoomCallback? callback) {
    int result = ZIMPlugin.leaveRoom(roomInfo.roomID);
    if (callback != null) {
      callback(result);
    }
  }

  void disableTextMessage(bool disable, RoomCallback? callback) {
    var json = jsonEncode(roomInfo);
    var map = {'room_info': json};
    var mapJson = jsonEncode(map);
    int result = ZIMPlugin.setRoomAttributes(roomInfo.roomID, mapJson, true);
    // TODO@oliver call in SDK async callback
    if (callback != null) {
      callback(result);
    }

    if (result == 0) {
      roomInfo.isTextMessageDisable = disable;
      notifyListeners();
    }
  }
}
