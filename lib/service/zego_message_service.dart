import 'package:flutter/foundation.dart';
import 'package:live_audio_room_flutter/plugin/ZIMPlugin.dart';
import 'package:live_audio_room_flutter/service/zego_room_manager.dart';

class ZegoTextMessage {
  // TODO@larry Add the member here.
  String message = "";
}

typedef ZegoRoomCallback = Function(int);
class ZegoMessageService extends ChangeNotifier {
  late List<ZegoTextMessage> messageList;

  ZegoMessageService() {
    // TODO@larry binding delegate to SDK and call notifyListeners() while data changed.
  }
  void sendTextMessage(String message, ZegoRoomCallback? callback) {
    var roomID = ZegoRoomManager.shared.roomService.roomInfo.roomID;
    int code = ZIMPlugin.sendRoomMessage(roomID, message, false);
    // Below code just for UI test
    if (code == 0) {
      var msg = ZegoTextMessage();
      msg.message = message;
      messageList.add(msg);
    }
    if (callback != null) {
      callback(code);
    }
    notifyListeners();
  }
}