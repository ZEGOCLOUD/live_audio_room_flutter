enum ZegoSpeakerSeatStatus { Untaken, Occupied, Closed }

enum ZegoNetworkQuality {
  Good,
  Medium,
  Bad,
  Unknow
}

class ZegoSpeakerSeat {
  String userID = "";
  int seatIndex = -1;
  bool mic = true;
  ZegoSpeakerSeatStatus status = ZegoSpeakerSeatStatus.Untaken;

  double soundLevel = 0.0;
  ZegoNetworkQuality network = ZegoNetworkQuality.Good;

  ZegoSpeakerSeat({required this.seatIndex});

  ZegoSpeakerSeat.fromJson(Map<String, dynamic> json)
      : userID = json['id'],
        seatIndex = json['index'],
        mic = json['mic'],
        status = ZegoSpeakerSeatStatus.values[json['status']];

  Map<String, dynamic> toJson() => {
        'id': userID,
        'index': seatIndex,
        'mic': mic,
        'status': status.index,
      };

  void clearData() {
    userID = "";
    mic = true;
    status = ZegoSpeakerSeatStatus.Untaken;
    soundLevel = 0.0;
    network = ZegoNetworkQuality.Good;
  }
}
