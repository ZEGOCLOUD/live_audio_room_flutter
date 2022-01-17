// ignore_for_file: avoid_print

import 'dart:ffi';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class ZIMPlugin {
  static const MethodChannel channel = MethodChannel('ZIMPlugin');

  static createZIM(int appID) {
    channel.invokeMethod("createZIM", {"appID": appID});
  }
  
  static destoryZIM() {
    channel.invokeMethod("destoryZIM");
  }

  static login(String userID, String userName, String token) {
    channel.invokeMethod("login", {"userID": userID, "userName": userName, "token": token});
  }

  static logout() {
    channel.invokeMethod("logout");
  }

  static createRoom(String roomID, String roomName) {
    channel.invokeMethod("createRoom", {"roomID": roomID, "roomName": roomName});
  }

  static joinRoom(String roomID) {
    channel.invokeMethod("joinRoom", {"roomID": roomID});
  }

  static leaveRoom(String roomID) {
    channel.invokeMethod("leaveRoom", {"roomID": roomID});
  }

  static uploadLog() {
    channel.invokeMethod("uploadLog");
  }

  static queryRoomAllAttributes(String roomID) {
    channel.invokeMethod("queryRoomAllAttributes", {"roomID", roomID});
  }

  static queryRoomOnlineMemberCount(String roomID) {
    channel.invokeMethod("queryRoomOnlineMemberCount", {"roomID", roomID});
  }

  static sendPeerMessage(String userID, String content, int actionType) {
    channel.invokeMethod("sendPeerMessage", {"userID": userID, "content": content, "actionType": actionType});
  }

  static sendRoomMessage(String roomID, String content, bool isCustomMessage) {
    channel.invokeMethod("sendRoomMessage", {"roomID": roomID, "content": content, 'isCustomMessage': isCustomMessage});
  }

  static setRoomAttributes(String roomID, String attributes, bool delete) {
    channel.invokeMethod("setRoomAttributes", {"roomID": roomID, "attributes": attributes, "delete": delete});
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