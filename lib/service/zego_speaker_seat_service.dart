import 'package:flutter/foundation.dart';
import 'package:live_audio_room_flutter/model/zego_speaker_seat.dart';

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
    speakerSeatList[seatIndex].userID = "";
    speakerSeatList[seatIndex].status =
        ZegoSpeakerSeatStatus.zegoSpeakerSeatStatusUntaken;
    notifyListeners();
  }

  void closeAllSeat(bool isClose, ZegoRoomCallback? callback) {
    // Ignore host
    for (var i = 1 ; i < speakerSeatList.length ; i++) {
      speakerSeatList[i].status = ZegoSpeakerSeatStatus.zegoSpeakerSeatStatusClosed;
    }
    notifyListeners();
  }

  void closeSeat(bool isClose, int seatIndex, ZegoRoomCallback? callback) {
    if (seatIndex < 1 || seatIndex >= 8) {
      return;
    }
    speakerSeatList[seatIndex].status = isClose
        ? ZegoSpeakerSeatStatus.zegoSpeakerSeatStatusClosed
        : ZegoSpeakerSeatStatus.zegoSpeakerSeatStatusUntaken;
    notifyListeners();
  }

  void muteMic(bool isMute, ZegoRoomCallback? callback) {
    localSpeakerSeat()?.mic = !isMute;
    notifyListeners();
  }

  void takeSeat(int seatIndex, ZegoRoomCallback? callback) {
    if (seatIndex < 1 || seatIndex >= 8) {
      return;
    }
    speakerSeatList[seatIndex].userID = _localUserID;
    speakerSeatList[seatIndex].status = ZegoSpeakerSeatStatus.zegoSpeakerSeatStatusOccupied;
    notifyListeners();
  }

  void leaveSeat(ZegoRoomCallback? callback) {
    var seat = localSpeakerSeat();
    seat?.userID = "";
    seat?.status = ZegoSpeakerSeatStatus.zegoSpeakerSeatStatusUntaken;
    if (callback!= null) {
      callback(0);
    }
    notifyListeners();
  }

  void switchSeat(int toSeatIndex, ZegoRoomCallback? callback) {
    if (toSeatIndex < 1 || toSeatIndex >= 8) {
      return;
    }
    leaveSeat((p0) {
      takeSeat(toSeatIndex, (p0) {
        if (callback != null) {
          callback(0);
        }
      });
    });

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
    speakerSeatList[0].status = ZegoSpeakerSeatStatus.zegoSpeakerSeatStatusOccupied;
    speakerSeatList[0].soundLevel = 1;

    speakerSeatList[1].userID = "222";
    speakerSeatList[1].status = ZegoSpeakerSeatStatus.zegoSpeakerSeatStatusOccupied;
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
