import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

class ZIMPlugin {
  static const MethodChannel channel = MethodChannel('ZIMPlugin');
  static const EventChannel event = EventChannel('ZIMPluginEventChannel');

  static void Function(int second)? onTokenWillExpire;

  static void Function(int state, int event)? onConnectionStateChanged;

  static void Function(String roomID, List<Map<String, dynamic>> memberList)? onRoomMemberJoined;
  static void Function(String roomID, List<Map<String, dynamic>> memberList)? onRoomMemberLeave;

  static void Function(String roomID, Map<String, dynamic> roomInfoJson)? onRoomInfoUpdate;
  static void Function(int state, int event)? onRoomStateChanged;
  static void Function(String roomID, Map<String, dynamic> speakerListJson)? onRoomSpeakerSeatUpdate;


  static void Function(String roomID, List<Map<String, dynamic>> textMessageListJson)? onReceiveTextRoomMessage;
  static void Function(String roomID, List<Map<String, dynamic>> customMessageListJson)? onReceiveCustomRoomMessage;
  static void Function(List<Map<String, dynamic>> customMessageListJson, String fromUserID)? onReceiveTextPeerMessage;
  static void Function(List<Map<String, dynamic>> customMessageListJson, String fromUserID)? onReceiveCustomPeerMessage;

  /// Used to receive the native event stream
  static StreamSubscription<dynamic>? streamSubscription;

  static Future<void> createZIM(int appID, String serverSecret) async {
    return await channel.invokeMethod("createZIM", {"appID": appID, "serverSecret": serverSecret});
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

  static Future<Map> renewToken(String token) async {
    return await channel.invokeMethod("renewToken", {"token": token});
  }

  static Future<Map> queryRoomAllAttributes(String roomID) async {
    return await channel.invokeMethod("queryRoomAllAttributes", {"roomID": roomID});
  }

  static Future<Map> queryRoomOnlineMemberCount(String roomID) async {
    return await channel.invokeMethod("queryRoomOnlineMemberCount", {"roomID": roomID});
  }

  static Future<Map> sendPeerMessage(String userID, String message, bool isCustomMessage) async {
    return await channel.invokeMethod("sendPeerMessage", {"userID": userID, "message": message, 'isCustomMessage': isCustomMessage});
  }

  static Future<Map> sendRoomMessage(String roomID, String message, bool isCustomMessage) async {
    return await channel.invokeMethod("sendRoomMessage", {"roomID": roomID, "message": message, 'isCustomMessage': isCustomMessage});
  }

  static Future<Map> setRoomAttributes(String roomID, String attributes, bool delete) async {
    return await channel.invokeMethod("setRoomAttributes", {"roomID": roomID, "attributes": attributes, "delete": delete});
  }

  static Future<Map> getToken(String userID) async {
    return await channel.invokeMethod("getToken", {"userID": userID});
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
        if (onRoomInfoUpdate == null) return;
        if (onRoomSpeakerSeatUpdate == null) return;
        var roomID = map['roomID'];
        var updateInfo = Map<String, dynamic>.from(jsonDecode(map['updateInfo']));
        if (updateInfo.containsKey('room_info')) {
          String jsonString = updateInfo['room_info'];
          if (jsonString.isNotEmpty) {
            var roomInfoJson = Map<String, dynamic>.from(jsonDecode(jsonString));
            onRoomInfoUpdate!(roomID, roomInfoJson);
          } else {
            onRoomInfoUpdate!(roomID, {});
          }
        }
        updateInfo.removeWhere((key, value) => key == "room_info");
        if (updateInfo.keys.isNotEmpty) {
          onRoomSpeakerSeatUpdate!(roomID, updateInfo);
        }
        break;
      case 'roomStateChanged':
        if (onRoomStateChanged == null) return;
        int state = map['state'];
        int event = map['event'];
        onRoomStateChanged!(state, event);
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
      case 'receiveTextPeerMessage':
        if (onReceiveTextPeerMessage == null) return;
        var textMessagesJson = List<Map<String, dynamic>>.from(jsonDecode(map['messageList']));
        var fromUserID = map['fromUserID'];
        onReceiveTextPeerMessage!(textMessagesJson, fromUserID);
        break;
      case 'receiveCustomPeerMessage':
        if (onReceiveCustomPeerMessage == null) return;
        var customMessageJson = List<Map<String, dynamic>>.from(jsonDecode(map['messageList']));
        var fromUserID = map['fromUserID'];
        onReceiveCustomPeerMessage!(customMessageJson, fromUserID);
        break;
      case 'connectionStateChanged':
        if (onConnectionStateChanged == null) return;
        int state = map['state'];
        int event = map['event'];
        onConnectionStateChanged!(state, event);
        break;
      case 'tokenWillExpire':
        if (onTokenWillExpire == null) return;
        int second = map['second'];
        onTokenWillExpire!(second);
        break;
      default:
        break;
    }
  }
}