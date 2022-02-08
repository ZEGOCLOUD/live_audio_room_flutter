import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:live_audio_room_flutter/plugin/zim_plugin.dart';
import 'package:live_audio_room_flutter/service/zego_room_manager.dart';

import 'package:live_audio_room_flutter/model/zego_speaker_seat.dart';
import 'package:live_audio_room_flutter/model/zego_room_info.dart';
import 'package:live_audio_room_flutter/constants/zego_room_constant.dart';
import 'package:live_audio_room_flutter/constants/zim_error_code.dart';

typedef ZegoRoomCallback = Function(int);

/// Class speaker seat management.
/// <p>Description: This class contains the logics related to speaker seat management, such as take/leave a speaker
/// seat,close a speaker seat, remove user from seat, change speaker seats, etc.</>
class ZegoSpeakerSeatService extends ChangeNotifier {
  /// The speaker seat list.
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
  bool get _isSeatClosed {
    return ZegoRoomManager.shared.roomService.roomInfo.isSeatClosed;
  }

  String get _localUserID {
    return ZegoRoomManager.shared.userService.localUserInfo.userID;
  }

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
    _roomID = "";
    _hostID = "";
    speakerIDSet.clear();
    for (final seat in seatList) {
      seat.clearData();
    }
  }

  onRoomEnter() {
    var roomInfo = ZegoRoomManager.shared.roomService.roomInfo;
    _roomID = roomInfo.roomID;
    _hostID = roomInfo.hostID;
    if (_hostID == _localUserID) {
      takeSeat(0);
    } else {
      var hostSeat = seatList[0];
      hostSeat.userID = _hostID;
      hostSeat.status = ZegoSpeakerSeatStatus.occupied;
      notifyListeners();
    }
  }

  /// Remove a user from speaker seat.
  /// <p>Description: This method can be used to remove a specified user (except the host) from the speaker seat. </>
  ///
  /// @param seatIndex refers to the seat index of the user you want to remove.
  Future<int> removeUserFromSeat(int seatIndex) async {
    var speakerSeat = seatList[seatIndex];
    var preUserID = speakerSeat.userID;
    var preStatus = speakerSeat.status;
    speakerSeat.userID = "";
    speakerSeat.status = _isSeatClosed
        ? ZegoSpeakerSeatStatus.closed
        : ZegoSpeakerSeatStatus.unTaken;
    String speakerSeatJson = jsonEncode(speakerSeat);
    Map speakerSeatMap = {"${speakerSeat.seatIndex}": speakerSeatJson};
    String attributes = jsonEncode(speakerSeatMap);
    var result = await ZIMPlugin.setRoomAttributes(_roomID, attributes, false);
    int code = result['errorCode'];
    if (ZIMErrorCodeExtension.valueMap[zimErrorCode.success] != code) {
      speakerSeat.userID = preUserID;
      speakerSeat.status = preStatus;
    }
    notifyListeners();
    return code;
  }

  /// Close all untaken speaker seat/Open all closed speaker seat.
  /// <p>Description: This method can be used to close all untaken seats or open all closed seats. And the status of
  /// the isSeatClosed will also be updated automatically.</>
  /// <p>Call this method at: After joining the room</>
  ///
  /// @param isClose  isClose can be used to close all untaken speaker seats.
  /// @param roomInfo
  Future<int> closeAllSeat(bool isClose, RoomInfo roomInfo) async {
    // Ignore host
    var map = {};
    for (var i = 0; i < seatList.length; i++) {
      var speakerSeat = seatList[i];
      if (speakerSeat.status == ZegoSpeakerSeatStatus.occupied) {
        continue;
      }
      speakerSeat.status = isClose
          ? ZegoSpeakerSeatStatus.closed
          : ZegoSpeakerSeatStatus.unTaken;
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

  /// lose specified untaken speaker seat/Open specified closed speaker seat.
  /// <p>Description: You can call this method to close untaken speaker seats, and the status of the specified speaker
  /// seat will change to closed or unused.</>
  /// <p>Call this method at: After joining the room</>
  ///
  /// @param isClose   can be used to close specified untaken speaker seats.
  /// @param seatIndex refers to the seat index of the seat that you want to close/open.
  Future<int> closeSeat(bool isClose, int seatIndex) async {
    var speakerSeat = seatList[seatIndex];
    var preStatus = speakerSeat.status;
    speakerSeat.status =
        isClose ? ZegoSpeakerSeatStatus.closed : ZegoSpeakerSeatStatus.unTaken;

    String speakerSeatJson = jsonEncode(speakerSeat);
    Map speakerSeatMap = {"${speakerSeat.seatIndex}": speakerSeatJson};
    String attributes = jsonEncode(speakerSeatMap);
    var result = await ZIMPlugin.setRoomAttributes(_roomID, attributes, false);
    int code = result['errorCode'];
    if (ZIMErrorCodeExtension.valueMap[zimErrorCode.success] != code) {
      speakerSeat.status = preStatus;
    }
    notifyListeners();
    return code;
  }

  /// Mute/Unmute your own microphone.
  /// <p>Description: This method can be used to mute/unmute your own microphone.</>
  /// <p>Call this method at:  After the host enters the room/listener takes a speaker seat</>
  ///
  /// @param isMuted  isMuted can be set to [true] to mute the microphone; or set it to [false] to unmute the
  ///                 microphone.
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

  /// Take the speaker seat.
  /// <p>Description: This method can be used to help a listener to take a speaker seat to speak. And at the same
  /// time,the microphone will be enabled, the audio streams will be published.</>
  /// <p>Call this method at:  After joining the room</>
  ///
  /// @param seatIndex seatIndex to take
  Future<int> takeSeat(int seatIndex) async {
    var speakerSeat = seatList[seatIndex];
    var preUserID = speakerSeat.userID;
    var preStatus = speakerSeat.status;
    speakerSeat.userID = _localUserID;
    speakerSeat.status = ZegoSpeakerSeatStatus.occupied;
    String speakerSeatJson = jsonEncode(speakerSeat);
    Map speakerSeatMap = {"${speakerSeat.seatIndex}": speakerSeatJson};
    String attributes = jsonEncode(speakerSeatMap);
    var result = await ZIMPlugin.setRoomAttributes(_roomID, attributes, false);
    int code = result['errorCode'];
    if (ZIMErrorCodeExtension.valueMap[zimErrorCode.success] != code) {
      speakerSeat.userID = preUserID;
      speakerSeat.status = preStatus;
    } else {
      var userStreamID = _roomID + "_" + _localUserID + "_main";
      ZegoExpressEngine.instance.startPublishingStream(userStreamID);
      ZegoExpressEngine.instance.muteMicrophone(!speakerSeat.mic);
    }
    updateSpeakerIDList();
    notifyListeners();
    return code;
  }

  /// leave the speaker seat.
  /// <p>Description: This method can be used to help a speaker to leave the speaker seat to become a listener again.
  /// And at the same time, the microphone will be disabled, the audio stream publishing will be stopped.</>
  /// <p>Call this method at:  After the listener takes a speaker seat</>
  Future<int> leaveSeat() async {
    var speakerSeat = _localSpeakerSeat();
    if (speakerSeat == null) {
      return -1;
    }
    var preUserID = speakerSeat.userID;
    var preStatus = speakerSeat.status;
    speakerSeat.userID = '';
    speakerSeat.status = _isSeatClosed
        ? ZegoSpeakerSeatStatus.closed
        : ZegoSpeakerSeatStatus.unTaken;
    String speakerSeatJson = jsonEncode(speakerSeat);
    Map speakerSeatMap = {"${speakerSeat.seatIndex}": speakerSeatJson};
    String attributes = jsonEncode(speakerSeatMap);
    var result = await ZIMPlugin.setRoomAttributes(_roomID, attributes, false);
    int code = result['errorCode'];
    if (ZIMErrorCodeExtension.valueMap[zimErrorCode.success] != code) {
      speakerSeat.userID = preUserID;
      speakerSeat.status = preStatus;
    } else {
      ZegoExpressEngine.instance.stopPublishingStream();
    }
    updateSpeakerIDList();
    notifyListeners();
    return code;
  }

  /// Change the speaker seats.
  /// <p>Description: This method can be used for users to change from the current speaker seat to another speaker
  /// seat, and make the current seat available.</>
  /// <p>Call this method at: After the listener takes a speaker seat</>
  ///
  /// @param toSeatIndex refers to the seat index of the seat that you want to switch to, you can only change to the
  ///                    open and untaken speaker seats.
  Future<int> switchSeat(int toSeatIndex) async {
    var fromSeat = _localSpeakerSeat();
    if (fromSeat == null) {
      return -1;
    }
    var toSeat = seatList[toSeatIndex];
    toSeat.userID = fromSeat.userID;
    toSeat.status = ZegoSpeakerSeatStatus.occupied;
    toSeat.mic = fromSeat.mic;
    fromSeat.userID = "";
    fromSeat.status = ZegoSpeakerSeatStatus.unTaken;
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
      return ZegoNetworkQuality.goodQuality;
    } else if (streamQuality == ZegoStreamQualityLevel.Medium) {
      return ZegoNetworkQuality.mediumQuality;
    } else if (streamQuality == ZegoStreamQualityLevel.Unknown) {
      return ZegoNetworkQuality.unknownQuality;
    } else {
      return ZegoNetworkQuality.badQuality;
    }
  }

  void updateSpeakerIDList() {
    speakerIDSet.clear();
    for (final seat in seatList) {
      if (seat.userID.isNotEmpty && seat.userID != _hostID) {
        speakerIDSet.add(seat.userID);
      }
    }
  }

  void updateUserIDSet(Set<String> idSet) {
    if (_hostID.isEmpty || _hostID != _localUserID) {
      return;
    }
    for (final seat in seatList) {
      if (seat.userID.isNotEmpty && !idSet.contains(seat.userID)) {
        removeUserFromSeat(seat.seatIndex);
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
