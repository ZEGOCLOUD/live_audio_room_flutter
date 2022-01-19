import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:live_audio_room_flutter/model/zego_speaker_seat.dart';
import 'package:live_audio_room_flutter/plugin/ZIMPlugin.dart';
import 'package:live_audio_room_flutter/service/zego_room_manager.dart';

typedef ZegoRoomCallback = Function(int);

class ZegoSpeakerSeatService extends ChangeNotifier {
  final List<ZegoSpeakerSeat> seatList = <ZegoSpeakerSeat>[
    ZegoSpeakerSeat(seatIndex: 0),
    ZegoSpeakerSeat(seatIndex: 1),
    ZegoSpeakerSeat(seatIndex: 2),
    ZegoSpeakerSeat(seatIndex: 3),
    ZegoSpeakerSeat(seatIndex: 4),
    ZegoSpeakerSeat(seatIndex: 5),
    ZegoSpeakerSeat(seatIndex: 6),
    ZegoSpeakerSeat(seatIndex: 7)
  ];
  List<String> speakerIDList = [];
  String _roomID = "";
  String _hostID = ""; // Sort host to index 0
  String _localUserID = "";

  ZegoSpeakerSeatService() {
    ZIMPlugin.onRoomSpeakerSeatUpdate = _onRoomSpeakerSeatUpdate;
  }

  Future<int> removeUserFromSeat(int seatIndex) async {
    var speakerSeat = seatList[seatIndex];
    var preUserID = speakerSeat.userID;
    var preStatus = speakerSeat.status;
    speakerSeat.userID = "";
    speakerSeat.status = ZegoSpeakerSeatStatus.Untaken;
    String speakerSeatJson = jsonEncode(speakerSeat);
    Map speakerSeatMap = {speakerSeat.seatIndex: speakerSeatJson};
    String attributes = jsonEncode(speakerSeatMap);
    var result = await ZIMPlugin.setRoomAttributes(_roomID, attributes, false);
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
    for (var i = 1; i < seatList.length; i++) {
      var speakerSeat = seatList[i];
      if (speakerSeat.status == ZegoSpeakerSeatStatus.Occupied) {
        continue;
      }
      speakerSeat.status = isClose
          ? ZegoSpeakerSeatStatus.Closed
          : ZegoSpeakerSeatStatus.Untaken;
      map[i] = jsonEncode(speakerSeat);
    }
    String attributes = jsonEncode(map);
    var result = await ZIMPlugin.setRoomAttributes(_roomID, attributes, false);
    return result['errorCode'];
  }

  Future<int> closeSeat(bool isClose, int seatIndex) async {
    var speakerSeat = seatList[seatIndex];
    var preStatus = speakerSeat.status;
    speakerSeat.status =
        isClose ? ZegoSpeakerSeatStatus.Closed : ZegoSpeakerSeatStatus.Untaken;

    String speakerSeatJson = jsonEncode(speakerSeat);
    Map speakerSeatMap = {speakerSeat.seatIndex: speakerSeatJson};
    String attributes = jsonEncode(speakerSeatMap);
    var result = await ZIMPlugin.setRoomAttributes(_roomID, attributes, false);
    int code = result['errorCode'];
    if (code != 0) {
      speakerSeat.status = preStatus;
    }
    notifyListeners();
    return code;
  }

  Future<int> muteMic(bool isMute, ZegoRoomCallback? callback) async {
    if (_localSpeakerSeat() == null) {
      return -1;
    }
    _localSpeakerSeat()?.mic = !isMute;

    String speakerSeatJson = jsonEncode(_localSpeakerSeat());
    Map speakerSeatMap = {_localSpeakerSeat()?.seatIndex: speakerSeatJson};
    String attributes = jsonEncode(speakerSeatMap);
    var result = await ZIMPlugin.setRoomAttributes(_roomID, attributes, false);
    notifyListeners();
    return result['errorCode'];
  }

  Future<int> takeSeat(int seatIndex) async {
    var speakerSeat = seatList[seatIndex];
    var preUserID = speakerSeat.userID;
    var preStatus = speakerSeat.status;
    speakerSeat.userID = _localUserID;
    speakerSeat.status = ZegoSpeakerSeatStatus.Occupied;
    String speakerSeatJson = jsonEncode(speakerSeat);
    Map speakerSeatMap = {"${speakerSeat.seatIndex}": speakerSeatJson};
    String attributes = jsonEncode(speakerSeatMap);
    var result = await ZIMPlugin.setRoomAttributes(_roomID, attributes, false);
    int code = result['errorCode'];
    if (code != 0) {
      speakerSeat.userID = preUserID;
      speakerSeat.status = preStatus;
    }
    updateSpeakerIDList();
    notifyListeners();
    return code;
  }

  Future<int> leaveSeat() async {
    var speakerSeat = _localSpeakerSeat();
    if (speakerSeat == null) {
      return -1;
    }
    var preUserID = speakerSeat.userID;
    var preStatus = speakerSeat.status;
    speakerSeat.userID = '';
    speakerSeat.status =
        ZegoRoomManager.shared.roomService.roomInfo.isSeatClosed
            ? ZegoSpeakerSeatStatus.Closed
            : ZegoSpeakerSeatStatus.Untaken;
    String speakerSeatJson = jsonEncode(speakerSeat);
    Map speakerSeatMap = {speakerSeat.seatIndex: speakerSeatJson};
    String attributes = jsonEncode(speakerSeatMap);
    var result = await ZIMPlugin.setRoomAttributes(_roomID, attributes, false);
    int code = result['errorCode'];
    if (code != 0) {
      speakerSeat.userID = preUserID;
      speakerSeat.status = preStatus;
    }
    notifyListeners();
    return code;
  }

  Future<int> switchSeat(int toSeatIndex) async {
    var fromSeat = _localSpeakerSeat();
    if (fromSeat == null) {
      return -1;
    }
    var toSeat = seatList[toSeatIndex];
    toSeat.userID = fromSeat.userID;
    toSeat.status = ZegoSpeakerSeatStatus.Occupied;
    toSeat.mic = fromSeat.mic;
    fromSeat.userID = "";
    fromSeat.status = ZegoSpeakerSeatStatus.Untaken;
    fromSeat.mic = false;
    String fromSeatJson = jsonEncode(fromSeat);
    String toSeatJson = jsonEncode(toSeat);
    Map speakerSeatMap = {
      fromSeat.seatIndex: fromSeatJson,
      toSeat.seatIndex: toSeatJson
    };
    String attributes = jsonEncode(speakerSeatMap);
    var result = await ZIMPlugin.setRoomAttributes(_roomID, attributes, false);
    notifyListeners();
    return result['errorCode'];
  }

  void _onRoomSpeakerSeatUpdate(
      String roomID, Map<String, dynamic> speakerSeat) {
    for (final seatJson in speakerSeat.values) {
      var speakerSeat = ZegoSpeakerSeat.fromJson(jsonDecode(seatJson));
      speakerSeatList[speakerSeat.seatIndex] = speakerSeat;
    }
    notifyListeners();
  }

  void updateSpeakerIDList() {
    speakerIDList.clear();
    for (var seat in seatList) {
      if (seat.userID.isNotEmpty && seat.userID != _hostID) {
        speakerIDList.add(seat.userID);
      }
    }
  }

  void updateHostID(String id) {
    _hostID = id;
  }

  void updateLocalUserID(String id) {
    _localUserID = id;
    seatList[0].userID = _hostID;
    seatList[0].status = id.isEmpty
        ? ZegoSpeakerSeatStatus.Untaken
        : ZegoSpeakerSeatStatus.Occupied;
    notifyListeners();
  }

  void updateRoomID(String id) {
    _roomID = id;
    if (id.isEmpty) {
      speakerIDList.clear();
      for (final seat in seatList) {
        seat.clearData();
      }
    }
  }

  ZegoSpeakerSeat? _localSpeakerSeat() {
    for (var seat in seatList) {
      if (seat.userID == _localUserID) {
        return seat;
      }
    }
    return null;
  }
}
