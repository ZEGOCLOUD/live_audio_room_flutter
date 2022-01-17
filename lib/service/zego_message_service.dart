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
  Future<int> sendTextMessage(String message, ZegoRoomCallback? callback) async {
    var roomID = ZegoRoomManager.shared.roomService.roomInfo.roomID;
    var result = await ZIMPlugin.sendRoomMessage(roomID, message, false);
    int code = result['errorCode'];
    if (code == 0) {
      var msg = ZegoTextMessage();
      msg.message = message;
      messageList.add(msg);
    }
    notifyListeners();
    return code;
  }
}