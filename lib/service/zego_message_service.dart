import 'package:flutter/foundation.dart';

import 'package:live_audio_room_flutter/plugin/ZIMPlugin.dart';
import 'package:live_audio_room_flutter/service/zego_room_manager.dart';
import 'package:live_audio_room_flutter/model/zego_user_info.dart';

class ZegoTextMessage {
  // TODO@larry Add the member here.
  String userID = "";
  String message = "";
  int timestamp = 0;
  int messageID = 0;
  int type = 0;

  ZegoTextMessage();

  ZegoTextMessage.formJson(Map<String, dynamic> json)
      : userID = json['userID'],
        message = json['message'],
        timestamp = json['timestamp'],
        messageID = json['messageID'],
        type = json['type'];

  Map<String, dynamic> toJson() => {
        'messageID': messageID,
        'userID': userID,
        'message': message,
        'timestamp': timestamp,
        'type': type
      };
}

typedef ZegoRoomCallback = Function(int);

class ZegoMessageService extends ChangeNotifier {
  List<ZegoTextMessage> messageList = [];
  String memberJoinedText = '';
  String memberLeaveText = '';

  ZegoMessageService() {
    ZIMPlugin.onReceiveTextRoomMessage = _onReceiveTextMessage;
  }

  onRoomLeave() {
    messageList.clear();
    memberJoinedText = '';
    memberLeaveText = '';
  }

  onRoomEnter() {}

  Future<int> sendTextMessage(
      String roomID, String userID, String message) async {
    var result = await ZIMPlugin.sendRoomMessage(roomID, message, false);
    int code = result['errorCode'];
    if (code == 0) {
      var msg = ZegoTextMessage();
      msg.message = message;
      msg.userID = userID;
      msg.timestamp = DateTime.now().millisecondsSinceEpoch;
      messageList.add(msg);
      notifyListeners();
    }
    return code;
  }

  void setTranslateTexts(String memberJoinedText, String memberLeaveText) {
    this.memberJoinedText = memberJoinedText;
    this.memberLeaveText = memberLeaveText;
  }

  void _onReceiveTextMessage(
      String roomID, List<Map<String, dynamic>> messageListJson) {
    for (final item in messageListJson) {
      var message = ZegoTextMessage.formJson(item);
      messageList.add(message);
    }
    notifyListeners();
  }

  void onRoomMemberJoined(List<ZegoUserInfo> members) {
    if (memberJoinedText.isEmpty) {
      return;
    }

    for (var member in members) {
      if (member.userID.isEmpty || member.userName.isEmpty) {
        return;
      }

      ZegoTextMessage message = ZegoTextMessage();
      message.message = memberJoinedText.replaceAll('%@', member.userName);
      messageList.add(message);
    }

    notifyListeners();
  }

  void onRoomMemberLeave(List<ZegoUserInfo> members) {
    if (memberLeaveText.isEmpty) {
      return;
    }

    for (var member in members) {
      if (member.userID.isEmpty || member.userName.isEmpty) {
        return;
      }

      ZegoTextMessage message = ZegoTextMessage();
      message.message = memberLeaveText.replaceAll('%@', member.userName);
      messageList.add(message);
    }

    notifyListeners();
  }
}
