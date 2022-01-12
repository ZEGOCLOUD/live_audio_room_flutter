import 'package:flutter/foundation.dart';
import 'package:live_audio_room_flutter/model/zego_speaker_seat.dart';

typedef ZegoRoomCallback = Function(int);

class ZegoSpeakerSeatService extends ChangeNotifier {
  List<ZegoSpeakerSeat> speakerSeatList = <ZegoSpeakerSeat>[];
  String _hostID = ""; // Sort host to index 0

  ZegoSpeakerSeatService() {
    // TODO@larry binding delegate to SDK and call notifyListeners() while data changed.
  }

  void removeUserFromSeat(int seatIndex, ZegoRoomCallback? callback) {}

  void closeAllSeat(bool isClose, ZegoRoomCallback? callback) {}

  void closeSeat(bool isClose, int seatIndex, ZegoRoomCallback? callback) {}

  void muteMic(bool isMute, ZegoRoomCallback? callback) {}

  void takeSeat(int seatIndex, ZegoRoomCallback? callback) {}

  void leaveSeat(ZegoRoomCallback? callback) {}

  void switchSeat(int toSeatIndex, ZegoRoomCallback? callback) {}

  void updateHostID(String id) {
    // TODO@larry sort seats by host id
    _hostID = id;
  }
  void generateFakeDataForUITest() {
    var hostSeat = ZegoSpeakerSeat();
    hostSeat.userID = "111";
    hostSeat.userName = "Host Name";
    hostSeat.soundLevel = 1;
    hostSeat.mic = true;
    hostSeat.seatIndex = 0;

    var speakerSeat = ZegoSpeakerSeat();
    speakerSeat.userID = "222";
    speakerSeat.userName = "Hello";
    speakerSeat.soundLevel = 0;
    speakerSeat.mic = false;
    speakerSeat.seatIndex = 1;

    speakerSeatList.add(hostSeat);
    speakerSeatList.add(speakerSeat);
    notifyListeners();
  }

  ZegoSpeakerSeat localSpeakerSeat() {
    // TODO@larry
    ZegoSpeakerSeat seat = ZegoSpeakerSeat();
    seat.mic = true;
    seat.userID = "111";
    seat.seatIndex = 0;
    return seat;
  }
}
