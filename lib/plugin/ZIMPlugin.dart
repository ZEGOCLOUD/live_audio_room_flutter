// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:ffi';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class ZIMPlugin {
  static const MethodChannel channel = MethodChannel('ZIMPlugin');
  static const EventChannel event = EventChannel('ZIMPluginEventChannel');

  static void Function(String roomID, List<Map<String, dynamic>> memberList)? onRoomMemberJoined;
  static void Function(String roomID, List<Map<String, dynamic>> memberList)? onRoomMemberLeave;

  static void Function(String roomID, Map<String, dynamic> roomInfoJson)? onRoomStatusUpdate;
  static void Function(String roomID, Map<String, dynamic> speakerListJson)? onRoomSpeakerSeatUpdate;

  /// Used to receive the native event stream
  static StreamSubscription<dynamic>? streamSubscription;

  static Future<void> createZIM(int appID, String appSign, String serverSecret) async {
    return await channel.invokeMethod("createZIM", {"appID": appID, "appSign": appSign, "serverSecret": serverSecret});
  }
  
  static Future<Map> destroyZIM() async {
    return await channel.invokeMethod("destroyZIM");
  }

  static Future<Map> login(String userID, String userName, String token) async {
    return await channel.invokeMethod("login", {"userID": userID, "userName": userName, "token": token});
  }

  static Future<Map> logout() async {
    return await channel.invokeMethod("logout");
  }

  static Future<Map> createRoom(String roomID, String roomName) async {
    return await channel.invokeMethod("createRoom", {"roomID": roomID, "roomName": roomName});
  }

  static Future<Map> joinRoom(String roomID) async {
    return await channel.invokeMethod("joinRoom", {"roomID": roomID});
  }

  static Future<Map> leaveRoom(String roomID) async {
    return await channel.invokeMethod("leaveRoom", {"roomID": roomID});
  }

  static Future<Map> uploadLog() async {
    return await channel.invokeMethod("uploadLog");
  }

  static Future<Map> queryRoomAllAttributes(String roomID) async {
    return await channel.invokeMethod("queryRoomAllAttributes", {"roomID": roomID});
  }

  static Future<Map> queryRoomOnlineMemberCount(String roomID) async {
    return await channel.invokeMethod("queryRoomOnlineMemberCount", {"roomID": roomID});
  }

  static Future<Map> sendPeerMessage(String userID, String content, int actionType) async {
    return await channel.invokeMethod("sendPeerMessage", {"userID": userID, "content": content, "actionType": actionType});
  }

  static Future<Map> sendRoomMessage(String roomID, String content, bool isCustomMessage) async {
    return await channel.invokeMethod("sendRoomMessage", {"roomID": roomID, "content": content, 'isCustomMessage': isCustomMessage});
  }

  static Future<Map> setRoomAttributes(String roomID, String attributes, bool delete) async {
    return await channel.invokeMethod("setRoomAttributes", {"roomID": roomID, "attributes": attributes, "delete": delete});
  }

  /* EventHandler */

  static void registerEventHandler() async {
    streamSubscription = event.receiveBroadcastStream().listen(eventListener);
  }

  static void unregisterEventHandler() async {
    await streamSubscription?.cancel();
    streamSubscription = null;
  }

  static void eventListener(dynamic data) {
    final Map<dynamic, dynamic> map = data;
    switch (map['method']) {
      case 'roomMemberJoined':
        var memberList = map['memberList'];
        String roomID = map['roomID'];
        if (onRoomMemberJoined != null) {
          onRoomMemberJoined!(roomID, memberList);
        }
        break;
      case 'onRoomMemberLeave':
        var memberList = map['memberList'];
        String roomID = map['roomID'];
        if (onRoomMemberLeave != null) {
          onRoomMemberLeave!(roomID, memberList);
        }
        break;
      case 'roomAttributesUpdated':
        var roomID = map['roomID'];
        var updateInfo = map['updateInfo'] as Map<String, dynamic>;
        var roomInfoJson = updateInfo['room_info'];
        if (roomInfoJson != null) {
          if (onRoomStatusUpdate != null) {
            onRoomStatusUpdate!(roomID, roomInfoJson);
          }
        }
        updateInfo.removeWhere((key, value) => key == "room_info");
        if (updateInfo.keys.isNotEmpty) {
          if (onRoomSpeakerSeatUpdate != null) {
            onRoomSpeakerSeatUpdate!(roomID, updateInfo);
          }
        }
        break;
      default:
      // TODO: Unknown callback
        break;
    }
  }
}