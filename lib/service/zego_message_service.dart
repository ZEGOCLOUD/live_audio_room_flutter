import 'package:flutter/foundation.dart';

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
    // TODO@larry call SDK.
    // Below code just for UI test
    var msg = ZegoTextMessage();
    msg.message = message;
    messageList.add(msg);
    notifyListeners();
  }
}