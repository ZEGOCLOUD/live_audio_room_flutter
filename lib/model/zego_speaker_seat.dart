import 'package:live_audio_room_flutter/constants/zego_room_constant.dart';

/// Class speaker seat status information.
/// <p>Description: This class contains the speaker seat status information.</>
class ZegoSpeakerSeat {
  /// User ID, null indicates the current speaker seat is available/untaken.
  String userID = "";
  /// The seat index.
  int seatIndex = -1;
  /// The speaker seat mic status.
  bool mic = true;
  /// The speaker seat status, it is untaken by default.
  ZegoSpeakerSeatStatus status = ZegoSpeakerSeatStatus.unTaken;
  /// Volume value, a local record attribute, used for displaying the sound level.
  double soundLevel = 0.0;
  /// status, a local record attributes. It is calculated based on stream quality, can be used for displaying the network status.
  ZegoNetworkQuality network = ZegoNetworkQuality.goodQuality;

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
    status = ZegoSpeakerSeatStatus.unTaken;
    soundLevel = 0.0;
    network = ZegoNetworkQuality.goodQuality;
  }
}
