import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:live_audio_room_flutter/plugin/ZIMPlugin.dart';
import 'package:live_audio_room_flutter/service/zego_room_manager.dart';

typedef ZegoRoomCallback = Function(int);

class ZegoGiftService extends ChangeNotifier {
  String giftSender = "";
  String giftName = "";
  List<String> giftReceivers = [];

  bool displayTips = false;
  late Timer displayTimer;

  Future<int> sendGift(String giftID, List<String> toUserList, ZegoRoomCallback? callback) async {
    Map message = {'actionType': 2, 'target': toUserList, 'content': {'giftID': giftID}};
    String json = jsonEncode(message);
    var result = await ZIMPlugin.sendRoomMessage(ZegoRoomManager.shared.roomService.roomInfo.roomID, json, true);
    int code = result['errorCode'];
    if (code == 0) {
      giftName = giftID;
      giftReceivers = toUserList;
      giftSender = "Some One";
    }
    notifyListeners();
    return code;
  }

  void onReceiveCustomMessage(String roomID, List<Map<String, dynamic>> messageListJson) {
    for (final item in messageListJson) {
      var messageJson = item['message'];
      Map<String, dynamic> messageDic = jsonDecode(messageJson);
      int actionType = messageDic['actionType'];
      if (actionType == 2) {
        giftName = messageDic['content']['giftID'];
        giftSender = item['userID'];
        giftReceivers = item['target'];
      }
    }

    if (displayTips) {
      displayTimer.cancel();
    }
    displayTips = true;
    displayTimer = Timer(const Duration(seconds: 10), () {
      displayTips = false; //  hide after 10 seconds
      notifyListeners();
    });

    notifyListeners();
  }
}
