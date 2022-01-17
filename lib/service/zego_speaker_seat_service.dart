import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:live_audio_room_flutter/model/zego_speaker_seat.dart';
import 'package:live_audio_room_flutter/plugin/ZIMPlugin.dart';
import 'package:live_audio_room_flutter/service/zego_room_manager.dart';

typedef ZegoRoomCallback = Function(int);

class ZegoSpeakerSeatService extends ChangeNotifier {
  final List<ZegoSpeakerSeat> speakerSeatList = <ZegoSpeakerSeat>[
    ZegoSpeakerSeat(seatIndex: 0),
    ZegoSpeakerSeat(seatIndex: 1),
    ZegoSpeakerSeat(seatIndex: 2),
    ZegoSpeakerSeat(seatIndex: 3),
    ZegoSpeakerSeat(seatIndex: 4),
    ZegoSpeakerSeat(seatIndex: 5),
    ZegoSpeakerSeat(seatIndex: 6),
    ZegoSpeakerSeat(seatIndex: 7)
  ];
  String _hostID = ""; // Sort host to index 0
  String _localUserID = "";
  Map userIDNameMap = {}; // Update while user service data updated for better performance.

  ZegoSpeakerSeatService() {
    // TODO@larry binding delegate to SDK and call notifyListeners() while data changed.
  }

  void removeUserFromSeat(int seatIndex, ZegoRoomCallback? callback) {
    if (seatIndex < 1 || seatIndex >= 8) {
      return;
    }
    var speakerSeat = speakerSeatList[seatIndex];
    speakerSeat.userID = "";
    speakerSeat.status = ZegoSpeakerSeatStatus.Untaken;
    String speakerSeatJson = jsonEncode(speakerSeat);
    Map speakerSeatMap = {speakerSeat.seatIndex : json};
    String attributes = jsonEncode(speakerSeatMap);
    int result = ZIMPlugin.setRoomAttributes(ZegoRoomManager.shared.roomService.roomInfo.roomID, attributes, false);
    if (callback != null) {
      callback(result);
    }
    notifyListeners();
  }

  void closeAllSeat(bool isClose, ZegoRoomCallback? callback) {
    // Ignore host
    var map = {};
    for (var i = 1 ; i < speakerSeatList.length ; i++) {
      var speakerSeat = speakerSeatList[i];
      if (speakerSeat.status == ZegoSpeakerSeatStatus.Occupied) { continue; }
      speakerSeat.status = isClose ? ZegoSpeakerSeatStatus.Closed : ZegoSpeakerSeatStatus.Untaken;
      map[i] = jsonEncode(speakerSeat);
    }
    String attributes = jsonEncode(map);
    int result = ZIMPlugin.setRoomAttributes(ZegoRoomManager.shared.roomService.roomInfo.roomID, attributes, false);
    if (callback != null) {
      callback(result);
    }
    notifyListeners();
  }

  void closeSeat(bool isClose, int seatIndex, ZegoRoomCallback? callback) {
    if (seatIndex < 1 || seatIndex >= 8) {
      return;
    }
    var speakerSeat = speakerSeatList[seatIndex];
    speakerSeat.status = isClose ? ZegoSpeakerSeatStatus.Closed : ZegoSpeakerSeatStatus.Untaken;

    String speakerSeatJson = jsonEncode(speakerSeat);
    Map speakerSeatMap = {speakerSeat.seatIndex : json};
    String attributes = jsonEncode(speakerSeatMap);
    int result = ZIMPlugin.setRoomAttributes(ZegoRoomManager.shared.roomService.roomInfo.roomID, attributes, false);
    if (callback != null) {
      callback(result);
    }
    notifyListeners();
  }

  void muteMic(bool isMute, ZegoRoomCallback? callback) {
    if (localSpeakerSeat() == null) { return; }
    localSpeakerSeat()?.mic = !isMute;

    String speakerSeatJson = jsonEncode(localSpeakerSeat());
    Map speakerSeatMap = {localSpeakerSeat()?.seatIndex : speakerSeatJson};
    String attributes = jsonEncode(speakerSeatMap);
    int result = ZIMPlugin.setRoomAttributes(ZegoRoomManager.shared.roomService.roomInfo.roomID, attributes, false);
    if (callback != null) {
      callback(result);
    }
    notifyListeners();
  }

  void takeSeat(int seatIndex, ZegoRoomCallback? callback) {
    if (seatIndex < 1 || seatIndex >= 8) {
      return;
    }

    var speakerSeat = speakerSeatList[seatIndex];
    speakerSeat.userID = ZegoRoomManager.shared.userService.localUserInfo.userID;
    speakerSeat.status = ZegoSpeakerSeatStatus.Occupied;
    String speakerSeatJson = jsonEncode(speakerSeat);
    Map speakerSeatMap = {speakerSeat.seatIndex : json};
    String attributes = jsonEncode(speakerSeatMap);
    int result = ZIMPlugin.setRoomAttributes(ZegoRoomManager.shared.roomService.roomInfo.roomID, attributes, false);
    if (callback != null) {
      callback(result);
    }

    notifyListeners();
  }

  void leaveSeat(ZegoRoomCallback? callback) {
    var speakerSeat = localSpeakerSeat();
    if (speakerSeat == null) { return; }
    speakerSeat.userID = '';
    speakerSeat.status = ZegoRoomManager.shared.roomService.roomInfo.isSeatClosed ? ZegoSpeakerSeatStatus.Closed : ZegoSpeakerSeatStatus.Untaken;
    String speakerSeatJson = jsonEncode(speakerSeat);
    Map speakerSeatMap = {speakerSeat.seatIndex : json};
    String attributes = jsonEncode(speakerSeatMap);
    int result = ZIMPlugin.setRoomAttributes(ZegoRoomManager.shared.roomService.roomInfo.roomID, attributes, false);
    if (callback != null) {
      callback(result);
    }

    notifyListeners();
  }

  void switchSeat(int toSeatIndex, ZegoRoomCallback? callback) {
    if (toSeatIndex < 1 || toSeatIndex >= 8) {
      return;
    }
    var fromSeat = localSpeakerSeat();
    if (fromSeat == null) { return; }
    var toSeat = speakerSeatList[toSeatIndex];
    toSeat.userID = fromSeat.userID;
    toSeat.status = ZegoSpeakerSeatStatus.Occupied;
    toSeat.mic = fromSeat.mic;
    fromSeat.userID = "";
    fromSeat.status = ZegoSpeakerSeatStatus.Untaken;
    fromSeat.mic = false;
    String fromSeatJson = jsonEncode(fromSeat);
    String toSeatJson = jsonEncode(toSeat);
    Map speakerSeatMap = {fromSeat.seatIndex : fromSeatJson, toSeat.seatIndex: toSeatJson};
    String attributes = jsonEncode(speakerSeatMap);
    int result = ZIMPlugin.setRoomAttributes(ZegoRoomManager.shared.roomService.roomInfo.roomID, attributes, false);
    if (callback != null) {
      callback(result);
    }

    notifyListeners();
  }

  void updateHostID(String id) {
    // TODO@larry sort seats by host id
    _hostID = id;
  }

  void updateLocalUserID(String id) {
    _localUserID = id;
  }

  void updateUserIDNameMap(Map map) {
    userIDNameMap = map;
  }

  void generateFakeDataForUITest() {
    speakerSeatList[0].userID = "111";
    speakerSeatList[0].status = ZegoSpeakerSeatStatus.Occupied;
    speakerSeatList[0].soundLevel = 1;

    speakerSeatList[1].userID = "222";
    speakerSeatList[1].status = ZegoSpeakerSeatStatus.Occupied;
    speakerSeatList[1].soundLevel = 0;
    notifyListeners();
  }

  ZegoSpeakerSeat? localSpeakerSeat() {
    for (var seat in speakerSeatList) {
      if (seat.userID == _localUserID) {
        return seat;
      }
    }
    return null;
  }
}
