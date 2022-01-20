import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:live_audio_room_flutter/plugin/ZIMPlugin.dart';
import 'package:live_audio_room_flutter/service/zego_room_manager.dart';

typedef ZegoRoomCallback = Function(int);

class ZegoGiftService extends ChangeNotifier {
  String giftSender = "";
  String giftID = "";
  List<String> giftReceivers = [];

  bool displayTips = false;
  late Timer displayTimer;
  
  ZegoGiftService() {
    ZIMPlugin.onReceiveCustomRoomMessage = _onReceiveCustomMessage;
  }


  Future<int> sendGift(String roomID, String giftID, List<String> toUserList) async {
    Map message = {'actionType': 2, 'target': toUserList, 'content': {'giftID': giftID}};
    String json = jsonEncode(message);
    var result = await ZIMPlugin.sendRoomMessage(roomID, json, true);
    int code = result['errorCode'];
    if (code == 0) {
      this.giftID = giftID;
      giftReceivers = toUserList;
      giftSender = "Some One";
    }
    notifyListeners();
    return code;
  }

  void _onReceiveCustomMessage(String roomID, List<Map<String, dynamic>> messageListJson) {
    for (final item in messageListJson) {
      var messageJson = item['message'];
      Map<String, dynamic> messageDic = jsonDecode(messageJson);
      int actionType = messageDic['actionType'];
      if (actionType == 2) {
        giftID = messageDic['content']['giftID'];
        giftSender = item['userID'];
        giftReceivers = messageDic['target'].cast<String>();
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
