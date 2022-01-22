// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:live_audio_room_flutter/service/zego_user_service.dart';

class ZIMPlugin {
  static const MethodChannel channel = MethodChannel('ZIMPlugin');
  static const EventChannel event = EventChannel('ZIMPluginEventChannel');

  static void Function(int state, int event)? onConnectionStateChanged;

  static void Function(String roomID, List<Map<String, dynamic>> memberList)? onRoomMemberJoined;
  static void Function(String roomID, List<Map<String, dynamic>> memberList)? onRoomMemberLeave;

  static void Function(String roomID, Map<String, dynamic> roomInfoJson)? onRoomStatusUpdate;
  static void Function(String roomID, Map<String, dynamic> speakerListJson)? onRoomSpeakerSeatUpdate;


  static void Function(String roomID, List<Map<String, dynamic>> textMessageListJson)? onReceiveTextRoomMessage;
  static void Function(String roomID, List<Map<String, dynamic>> customMessageListJson)? onReceiveCustomRoomMessage;
  static void Function(List<Map<String, dynamic>> customMessageListJson)? onReceiveCustomPeerMessage;

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

  static Future<Map> createRoom(String roomID, String roomName, String hostID, int seatNum) async {
    return await channel.invokeMethod("createRoom", {"roomID": roomID, "roomName": roomName, "hostID": hostID, "seatNum": seatNum});
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

  static Future<Map> getRTCToken(String roomID, String userID) async {
    return await channel.invokeMethod("getRTCToken", {"roomID": roomID, "userID": userID});
  }

  static Future<Map> getZIMVersion() async {
    return await channel.invokeMethod("getZIMVersion", {});
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
        if (onRoomMemberJoined == null) return;
        var roomID = map['roomID'];
        var list = map['memberList'];
        List<Map<String, dynamic>> memberArray = [];
        for (final item in list) {
          memberArray.add(Map<String, dynamic>.from(item));
        }
        ZIMPlugin.onRoomMemberJoined!(roomID, memberArray);
        break;
      case 'roomMemberLeave':
        if (onRoomMemberLeave == null) return;
        var roomID = map['roomID'];
        var list = map['memberList'];
        List<Map<String, dynamic>> memberArray = [];
        for (final item in list) {
          memberArray.add(Map<String, dynamic>.from(item));
        }
        onRoomMemberLeave!(roomID, memberArray);
        break;
      case 'roomAttributesUpdated':
        if (onRoomStatusUpdate == null) return;
        if (onRoomSpeakerSeatUpdate == null) return;
        var roomID = map['roomID'];
        var updateInfo = Map<String, dynamic>.from(jsonDecode(map['updateInfo']));
        if (updateInfo.containsKey('room_info')) {
          var roomInfoJson = Map<String, dynamic>.from(jsonDecode(updateInfo['room_info']));
          onRoomStatusUpdate!(roomID, roomInfoJson);
        }
        updateInfo.removeWhere((key, value) => key == "room_info");
        if (updateInfo.keys.isNotEmpty) {
          onRoomSpeakerSeatUpdate!(roomID, updateInfo);
        }
        break;
      case 'receiveTextRoomMessage':
        if (onReceiveTextRoomMessage == null) return;
        var textMessagesJson = List<Map<String, dynamic>>.from(jsonDecode(map['messageList']));
        var roomID = map['roomID'];
        onReceiveTextRoomMessage!(roomID, textMessagesJson);
        break;
      case 'receiveCustomRoomMessage':
        if (onReceiveCustomRoomMessage == null) return;
        var customMessageJson = List<Map<String, dynamic>>.from(jsonDecode(map['messageList']));
        var roomID = map['roomID'];
        onReceiveCustomRoomMessage!(roomID, customMessageJson);
        break;
      case 'receiveCustomPeerMessage':
        if (onReceiveCustomPeerMessage == null) return;
        var customMessageJson = List<Map<String, dynamic>>.from(jsonDecode(map['messageList']));
        onReceiveCustomPeerMessage!(customMessageJson);
        break;
      case 'connectionStateChanged':
        if (onConnectionStateChanged == null) return;
        int state = map['state'];
        int event = map['event'];
        onConnectionStateChanged!(state, event);
        break;
      default:
        break;
    }
  }
}