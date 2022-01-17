// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:ffi';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class ZIMPlugin {
  static const MethodChannel channel = MethodChannel('ZIMPlugin');

  static Future<Map> createZIM(int appID) async {
    return await channel.invokeMethod("createZIM", {"appID": appID});
  }
  
  static Future<Map> destoryZIM() async {
    return await channel.invokeMethod("destoryZIM");
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
    return await channel.invokeMethod("queryRoomAllAttributes", {"roomID", roomID});
  }

  static Future<Map> queryRoomOnlineMemberCount(String roomID) async {
    return await channel.invokeMethod("queryRoomOnlineMemberCount", {"roomID", roomID});
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

  static configEventHandle() {

    const standardMethod = StandardMethodCodec();
    // ServicesBinding.instance?.defaultBinaryMessenger
    //     .setMockMessageHandler('ZIMPluginEventChannel', (message) async {
    //   // Decode the message into MethodCallHandler.
    //   final methodCall = standardMethod.decodeMethodCall(message);
    //
    //   if (methodCall.method == 'listen') {
    //   } else if (methodCall.method == 'cancel') {
    //   } else {
    //   }
    //
    // });
  }


}