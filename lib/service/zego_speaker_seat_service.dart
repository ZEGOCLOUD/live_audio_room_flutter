import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:live_audio_room_flutter/model/zego_speaker_seat.dart';
import 'package:live_audio_room_flutter/plugin/ZIMPlugin.dart';
import 'package:live_audio_room_flutter/service/zego_room_manager.dart';
import 'package:live_audio_room_flutter/service/zego_room_service.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

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
  Set<String> speakerIDSet = {};
  String _roomID = "";
  String _hostID = ""; // Sort host to index 0
  String _localUserID = "";
  bool _isSeatClosed = false;

  bool get isMute {
    if (_localSpeakerSeat() == null) {
      return true;
    } else {
      return !_localSpeakerSeat()!.mic;
    }
  }

  ZegoSpeakerSeatService() {
    ZIMPlugin.onRoomSpeakerSeatUpdate = _onRoomSpeakerSeatUpdate;

    ZegoExpressEngine.onCapturedSoundLevelUpdate = _onCapturedSoundLevelUpdate;
    ZegoExpressEngine.onRemoteSoundLevelUpdate = _onRemoteSoundLevelUpdate;
    ZegoExpressEngine.onNetworkQuality = _onNetworkQuality;
  }

  onRoomLeave() {
    leaveSeat();

    speakerIDSet.clear();
    for (final seat in seatList) {
      seat.clearData();
    }
  }

  Future<int> removeUserFromSeat(int seatIndex) async {
    var speakerSeat = seatList[seatIndex];
    var preUserID = speakerSeat.userID;
    var preStatus = speakerSeat.status;
    speakerSeat.userID = "";
    speakerSeat.status = ZegoSpeakerSeatStatus.Untaken;
    String speakerSeatJson = jsonEncode(speakerSeat);
    Map speakerSeatMap = {"${speakerSeat.seatIndex}": speakerSeatJson};
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

  Future<int> closeAllSeat(bool isClose, RoomInfo roomInfo) async {
    // Ignore host
    var map = {};
    for (var i = 0; i < seatList.length; i++) {
      var speakerSeat = seatList[i];
      if (speakerSeat.status == ZegoSpeakerSeatStatus.Occupied) {
        continue;
      }
      speakerSeat.status = isClose
          ? ZegoSpeakerSeatStatus.Closed
          : ZegoSpeakerSeatStatus.Untaken;
      map[i.toString()] = jsonEncode(speakerSeat);
    }

    //  set room_info attribute
    roomInfo.isSeatClosed = isClose;
    var json = jsonEncode(roomInfo);
    map['room_info'] = json;
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
    Map speakerSeatMap = {"${speakerSeat.seatIndex}": speakerSeatJson};
    String attributes = jsonEncode(speakerSeatMap);
    var result = await ZIMPlugin.setRoomAttributes(_roomID, attributes, false);
    int code = result['errorCode'];
    if (code != 0) {
      speakerSeat.status = preStatus;
    }
    notifyListeners();
    return code;
  }

  Future<int> toggleMic() async {
    if (_localSpeakerSeat() == null) {
      return -1;
    }
    _localSpeakerSeat()!.mic = !_localSpeakerSeat()!.mic;

    String speakerSeatJson = jsonEncode(_localSpeakerSeat());
    Map speakerSeatMap = {"${_localSpeakerSeat()?.seatIndex}": speakerSeatJson};
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
    } else {
      var userStreamID = _roomID + "_" + _localUserID + "_main";
      ZegoExpressEngine.instance.startPublishingStream(userStreamID);
      ZegoExpressEngine.instance.muteMicrophone(speakerSeat.mic == false);
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
    speakerSeat.status = _isSeatClosed
        ? ZegoSpeakerSeatStatus.Closed
        : ZegoSpeakerSeatStatus.Untaken;
    String speakerSeatJson = jsonEncode(speakerSeat);
    Map speakerSeatMap = {"${speakerSeat.seatIndex}": speakerSeatJson};
    String attributes = jsonEncode(speakerSeatMap);
    var result = await ZIMPlugin.setRoomAttributes(_roomID, attributes, false);
    int code = result['errorCode'];
    if (code != 0) {
      speakerSeat.userID = preUserID;
      speakerSeat.status = preStatus;
    } else {
      ZegoExpressEngine.instance.stopPublishingStream();
    }
    updateSpeakerIDList();
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
      "${fromSeat.seatIndex}": fromSeatJson,
      "${toSeat.seatIndex}": toSeatJson
    };
    String attributes = jsonEncode(speakerSeatMap);
    var result = await ZIMPlugin.setRoomAttributes(_roomID, attributes, false);
    updateSpeakerIDList();
    notifyListeners();
    return result['errorCode'];
  }

  void _onRoomSpeakerSeatUpdate(
      String roomID, Map<String, dynamic> speakerSeat) {
    for (final seatJson in speakerSeat.values) {
      var speakerSeat = ZegoSpeakerSeat.fromJson(jsonDecode(seatJson));
      seatList[speakerSeat.seatIndex] = speakerSeat;
      if (speakerSeat.userID == _localUserID) {
        var userStreamID = _roomID + "_" + _localUserID + "_main";
        ZegoExpressEngine.instance.startPublishingStream(userStreamID);
        ZegoExpressEngine.instance.muteMicrophone(speakerSeat.mic == false);
      }
    }
    updateSpeakerIDList();
    notifyListeners();
  }

  void _onCapturedSoundLevelUpdate(double soundLevel) {
    for (final speaker in seatList) {
      if (speaker.userID == _localUserID) {
        speaker.soundLevel = soundLevel;
      }
    }
    notifyListeners();
  }

  void _onRemoteSoundLevelUpdate(Map<String, double> soundLevels) {
    for (final streamID in soundLevels.keys) {
      for (final speaker in seatList) {
        var userStreamID = _roomID + "_" + speaker.userID + "_main";
        if (userStreamID == streamID) {
          var sound = soundLevels[streamID];
          speaker.soundLevel = sound!;
        }
      }
    }
    notifyListeners();
  }

  void _onNetworkQuality(String userID, ZegoStreamQualityLevel upstreamQuality,
      ZegoStreamQualityLevel downstreamQuality) {
    for (final seat in seatList) {
      if (_localUserID == seat.userID) {
        seat.network = getNetWorkQuality(upstreamQuality);
      } else {
        seat.network = getNetWorkQuality(downstreamQuality);
      }
    }
  }

  ZegoNetworkQuality getNetWorkQuality(ZegoStreamQualityLevel streamQuality) {
    if (streamQuality == ZegoStreamQualityLevel.Excellent ||
        streamQuality == ZegoStreamQualityLevel.Good) {
      return ZegoNetworkQuality.Good;
    } else if (streamQuality == ZegoStreamQualityLevel.Medium) {
      return ZegoNetworkQuality.Medium;
    } else if (streamQuality == ZegoStreamQualityLevel.Unknown) {
      return ZegoNetworkQuality.Unknow;
    } else {
      return ZegoNetworkQuality.Bad;
    }
  }

  void updateSpeakerIDList() {
    speakerIDSet.clear();
    for (var seat in seatList) {
      if (seat.userID.isNotEmpty && seat.userID != _hostID) {
        speakerIDSet.add(seat.userID);
      }
    }
  }

  void updateLocalUserID(String id) {
    if (id == _localUserID) {
      return;
    }
    _localUserID = id;
  }

  void updateRoomInfo(String roomID, String hostID, bool isSeatClosed) {
    if (roomID != _roomID) {
      _roomID = roomID;
    }
    if (isSeatClosed != _isSeatClosed) {
      _isSeatClosed = isSeatClosed;
    }
    if (hostID != _hostID) {
      _hostID = hostID;
      if (hostID.isNotEmpty) {
        if (_hostID == _localUserID) {
          takeSeat(0);
        } else {
          var hostSeat = seatList[0];
          hostSeat.userID = _hostID;
          hostSeat.status = ZegoSpeakerSeatStatus.Occupied;
          notifyListeners();
        }
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
