import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:live_audio_room_flutter/plugin/ZIMPlugin.dart';
import 'package:live_audio_room_flutter/service/zego_room_manager.dart';

typedef ZegoRoomCallback = Function(int);

class ZegoGiftService extends ChangeNotifier {
  String giftSender = "";
  String giftName = "";
  List<String> giftReceivers = [];

  void sendGift(String giftID, List<String> toUserList, ZegoRoomCallback? callback) {
    Map message = {'actionType': 2, 'target': toUserList, 'content': {'giftID': giftID}};
    String json = jsonEncode(message);
    int result = ZIMPlugin.sendRoomMessage(ZegoRoomManager.shared.roomService.roomInfo.roomID, json, true);
    if (callback != null) {
      callback(result);
      giftName = giftID;
      giftReceivers = toUserList;
      giftSender = "Some One";
    }

    notifyListeners();
  }
}
