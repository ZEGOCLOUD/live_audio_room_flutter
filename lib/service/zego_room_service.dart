import 'package:flutter/foundation.dart';

class RoomInfo {
  String roomId = "";
  String roomName = "";
  String hostId = "";
  int seatNum = 0;
  bool isTextMessageDisable = false;
  bool isSeatClosed = false;

}

typedef RoomCallback = Function(int);
class ZegoRoomService extends ChangeNotifier {
  late RoomInfo roomInfo;

  void createRoom(String roomId, String roomName, String token, RoomCallback? callback) {
    roomInfo.roomId = roomId;
    roomInfo.roomName = roomName;
    if (callback != null) {

      callback(0);

      notifyListeners();
    }
  }

  void joinRoom(String roomId, String token, RoomCallback? callback) {
    // TODO@oliver call SDK join room
    // TODO@oliver place the code below to SDK callback and set the info field with correct value.
    roomInfo.hostId = "";
    roomInfo.seatNum = 0;
    roomInfo.isTextMessageDisable = false;
    roomInfo.isSeatClosed = false;

    notifyListeners();
  }

  void leaveRoom(RoomCallback callback) {
    // TODO@oliver call SDK leave room and reset room info
    notifyListeners();
  }

  void disableTextMessage(bool disable, RoomCallback? callback) {
    // TODO@oliver call SDK method and update state on callback.
    roomInfo.isTextMessageDisable = false;
    notifyListeners();
  }
}