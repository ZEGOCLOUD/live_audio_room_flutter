import 'dart:convert';
import 'dart:html';

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

  Future<int> removeUserFromSeat(int seatIndex) async {
    var speakerSeat = speakerSeatList[seatIndex];
    var preUserID = speakerSeat.userID;
    var preStatus = speakerSeat.status;
    speakerSeat.userID = "";
    speakerSeat.status = ZegoSpeakerSeatStatus.Untaken;
    String speakerSeatJson = jsonEncode(speakerSeat);
    Map speakerSeatMap = {speakerSeat.seatIndex : speakerSeatJson};
    String attributes = jsonEncode(speakerSeatMap);
    var result = await ZIMPlugin.setRoomAttributes(ZegoRoomManager.shared.roomService.roomInfo.roomID, attributes, false);
    int code = result['errorCode'];
    if (code != 0) {
      speakerSeat.userID = preUserID;
      speakerSeat.status = preStatus;
    }
    notifyListeners();
    return code;
  }

  Future<int> closeAllSeat(bool isClose, ZegoRoomCallback? callback) async {
    // Ignore host
    var map = {};
    for (var i = 1 ; i < speakerSeatList.length ; i++) {
      var speakerSeat = speakerSeatList[i];
      if (speakerSeat.status == ZegoSpeakerSeatStatus.Occupied) { continue; }
      speakerSeat.status = isClose ? ZegoSpeakerSeatStatus.Closed : ZegoSpeakerSeatStatus.Untaken;
      map[i] = jsonEncode(speakerSeat);
    }
    String attributes = jsonEncode(map);
    var result = await ZIMPlugin.setRoomAttributes(ZegoRoomManager.shared.roomService.roomInfo.roomID, attributes, false);
    return result['errorCode'];
  }

  Future<int> closeSeat(bool isClose, int seatIndex) async {
    var speakerSeat = speakerSeatList[seatIndex];
    var preStatus = speakerSeat.status;
    speakerSeat.status = isClose ? ZegoSpeakerSeatStatus.Closed : ZegoSpeakerSeatStatus.Untaken;

    String speakerSeatJson = jsonEncode(speakerSeat);
    Map speakerSeatMap = {speakerSeat.seatIndex : speakerSeatJson};
    String attributes = jsonEncode(speakerSeatMap);
    var result = await ZIMPlugin.setRoomAttributes(ZegoRoomManager.shared.roomService.roomInfo.roomID, attributes, false);
    int code = result['errorCode'];
    if (code != 0) {
      speakerSeat.status = preStatus;
    }
    notifyListeners();
    return code;
  }

  Future<int> muteMic(bool isMute, ZegoRoomCallback? callback) async {
    if (localSpeakerSeat() == null) { return -1; }
    localSpeakerSeat()?.mic = !isMute;

    String speakerSeatJson = jsonEncode(localSpeakerSeat());
    Map speakerSeatMap = {localSpeakerSeat()?.seatIndex : speakerSeatJson};
    String attributes = jsonEncode(speakerSeatMap);
    var result = await ZIMPlugin.setRoomAttributes(ZegoRoomManager.shared.roomService.roomInfo.roomID, attributes, false);
    notifyListeners();
    return result['errorCode'];
  }

  Future<int> takeSeat(int seatIndex) async {
    var speakerSeat = speakerSeatList[seatIndex];
    var preUserID = speakerSeat.userID;
    var preStatus = speakerSeat.status;
    speakerSeat.userID = ZegoRoomManager.shared.userService.localUserInfo.userID;
    speakerSeat.status = ZegoSpeakerSeatStatus.Occupied;
    String speakerSeatJson = jsonEncode(speakerSeat);
    Map speakerSeatMap = {speakerSeat.seatIndex : speakerSeatJson};
    String attributes = jsonEncode(speakerSeatMap);
    var result = await ZIMPlugin.setRoomAttributes(ZegoRoomManager.shared.roomService.roomInfo.roomID, attributes, false);
    int code = result['errorCode'];
    if (code != 0) {
      speakerSeat.userID = preUserID;
      speakerSeat.status = preStatus;
    }
    notifyListeners();
    return code;
  }

  Future<int> leaveSeat() async {
    var speakerSeat = localSpeakerSeat();
    if (speakerSeat == null) { return -1; }
    var preUserID = speakerSeat.userID;
    var preStatus = speakerSeat.status;
    speakerSeat.userID = '';
    speakerSeat.status = ZegoRoomManager.shared.roomService.roomInfo.isSeatClosed ? ZegoSpeakerSeatStatus.Closed : ZegoSpeakerSeatStatus.Untaken;
    String speakerSeatJson = jsonEncode(speakerSeat);
    Map speakerSeatMap = {speakerSeat.seatIndex : speakerSeatJson};
    String attributes = jsonEncode(speakerSeatMap);
    var result = await ZIMPlugin.setRoomAttributes(ZegoRoomManager.shared.roomService.roomInfo.roomID, attributes, false);
    int code = result['errorCode'];
    if (code != 0) {
      speakerSeat.userID = preUserID;
      speakerSeat.status = preStatus;
    }
    notifyListeners();
    return code;
  }

  Future<int> switchSeat(int toSeatIndex) async {
    var fromSeat = localSpeakerSeat();
    if (fromSeat == null) { return -1; }
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
    var result = await ZIMPlugin.setRoomAttributes(ZegoRoomManager.shared.roomService.roomInfo.roomID, attributes, false);
    notifyListeners();
    return result['errorCode'];
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
