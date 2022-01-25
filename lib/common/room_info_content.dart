enum RoomInfoType {
  none,
  textMessageDisable,
  roomEndByHost,
  roomNetworkLeave,
  roomNetworkTempBroken,
  roomNetworkReconnected,
  roomNetworkReconnectedTimeout,
  loginUserKickOut,
}

extension RoomInfoTypeExtension on RoomInfoType {
  static const valueMap = {
    RoomInfoType.none: -1,
    RoomInfoType.textMessageDisable: 0,
    RoomInfoType.roomEndByHost: 1,
    RoomInfoType.roomNetworkLeave: 2,
    RoomInfoType.roomNetworkTempBroken: 3,
    RoomInfoType.roomNetworkReconnected: 4,
    RoomInfoType.roomNetworkReconnectedTimeout: 5,
    RoomInfoType.loginUserKickOut: 6,
  };

  static const Map<int, RoomInfoType> mapValue = {
    -1: RoomInfoType.none,
    0: RoomInfoType.textMessageDisable,
    1: RoomInfoType.roomEndByHost,
    2: RoomInfoType.roomNetworkLeave,
    3: RoomInfoType.roomNetworkTempBroken,
    4: RoomInfoType.roomNetworkReconnected,
    5: RoomInfoType.roomNetworkReconnectedTimeout,
    6: RoomInfoType.loginUserKickOut,
  };
}

class RoomInfoContent {
  RoomInfoType toastType = RoomInfoType.none;
  String message = '';

  RoomInfoContent.empty();

  RoomInfoContent(this.toastType, this.message);

  RoomInfoContent.fromJson(Map<String, dynamic> json) {
    int typeIntValue = json['type'];
    toastType = RoomInfoTypeExtension.mapValue[typeIntValue] as RoomInfoType;
    message = json['message'];
  }

  Map<String, dynamic> toJson() =>
      {'type': RoomInfoTypeExtension.valueMap[toastType], 'message': message};
}
