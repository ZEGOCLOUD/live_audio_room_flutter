import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:live_audio_room_flutter/plugin/ZIMPlugin.dart';
import 'package:live_audio_room_flutter/service/zego_room_manager.dart';

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
  Map<String, dynamic> toJson() =>
      {
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

  ZegoRoomService() {
    // TODO@larry binding delegate to SDK and call notifyListeners() while data changed.
  }

  void createRoom(String roomId, String roomName, String token, RoomCallback? callback) {
    int  code = ZIMPlugin.createRoom(roomId, roomName);
    if (code == 0) {
      roomInfo = RoomInfo(roomId, roomName, ZegoRoomManager.shared.userService.localUserInfo.userID);
    }
    if (callback != null) {
      callback(0);
    }
    notifyListeners();
  }

  void joinRoom(String roomId, String token, RoomCallback? callback) {
    String result = ZIMPlugin.joinRoom(roomId);
    roomInfo = new RoomInfo.formJson(jsonDecode(result));
    if (callback != null) {
      var code = 0;
      if (roomInfo.roomID.length == 0) { code = -1; }
      callback(code);
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
    roomInfo.isTextMessageDisable = disable;
    var json = jsonEncode(roomInfo);
    var map = { 'room_info': json };
    var mapJson = jsonEncode(map);
    int result = ZIMPlugin.setRoomAttributes(roomInfo.roomID, mapJson, true);
    if (callback != null) {
      callback(result);
    }
  }
}