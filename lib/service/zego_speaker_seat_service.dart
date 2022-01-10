
import 'package:flutter/foundation.dart';
import 'package:live_audio_room_flutter/model/zego_speaker_seat.dart';

typedef ZegoRoomCallback = Function(int);
class ZegoSpeakerSeatService extends ChangeNotifier  {
  late List<ZegoSpeakerSeat> _speakerSeatList;

  ZegoSpeakerSeatService() {
    // TODO@larry binding delegate to SDK and call notifyListeners() while data changed.
  }

  void removeUserFromSeat(int seatIndex, ZegoRoomCallback? callback){

  }

  void closeAllSeat(bool isClose, ZegoRoomCallback? callback) {

  }

  void closeSeat(bool isClose, int seatIndex, ZegoRoomCallback? callback) {

  }

  void muteMic(bool isMute, ZegoRoomCallback? callback) {

  }

  void takeSeat(int seatIndex, ZegoRoomCallback? callback) {

  }

  void leaveSeat(ZegoRoomCallback? callback) {

  }

  void switchSeat(int toSeatIndex, ZegoRoomCallback? callback){

  }

  ZegoSpeakerSeat localSpeakerSeat() {
    // TODO@larry
    return ZegoSpeakerSeat();
  }

}