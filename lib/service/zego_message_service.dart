import 'package:flutter/foundation.dart';
import 'package:live_audio_room_flutter/plugin/ZIMPlugin.dart';
import 'package:live_audio_room_flutter/service/zego_room_manager.dart';

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
  Map<String, dynamic> toJson() =>
      {
        'userID': userID,
        'message': message,
        'timestamp': timestamp,
        'messageID': messageID,
        'type': type
      };
}

typedef ZegoRoomCallback = Function(int);
class ZegoMessageService extends ChangeNotifier {
  late List<ZegoTextMessage> messageList;

  ZegoMessageService() {
    // TODO@larry binding delegate to SDK and call notifyListeners() while data changed.
  }
  Future<int> sendTextMessage(String message, ZegoRoomCallback? callback) async {
    var roomID = ZegoRoomManager.shared.roomService.roomInfo.roomID;
    var result = await ZIMPlugin.sendRoomMessage(roomID, message, false);
    int code = result['errorCode'];
    if (code == 0) {
      var msg = ZegoTextMessage();
      msg.message = message;
      messageList.add(msg);
      notifyListeners();
    }
    return code;
  }

  void onReceiveTextMessage(String roomID, List<Map<String, dynamic>> messageListJson) {
    for (final item in messageListJson) {
      var message = new ZegoTextMessage.formJson(item);
      messageList.add(message);
    }
    notifyListeners();
  }

}