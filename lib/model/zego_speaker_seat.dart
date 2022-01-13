
enum ZegoSpeakerSeatStatus {
  zegoSpeakerSeatStatusUntaken,
  zegoSpeakerSeatStatusOccupied,
  zegoSpeakerSeatStatusClosed
}

class ZegoSpeakerSeat {
  String userID = "";
  int seatIndex = -1;
  bool mic = false;
  ZegoSpeakerSeatStatus status = ZegoSpeakerSeatStatus.zegoSpeakerSeatStatusUntaken;

  double soundLevel = 0.0;
  double network = 0.0;
  ZegoSpeakerSeat({required this.seatIndex});
}