enum RoomToastType {
  none,
  textMessageDisable,
  roomEndByHost,
  roomNetworkLeave,
}

extension RoomToastTypeExtension on RoomToastType {
  static const valueMap = {
    RoomToastType.none: -1,
    RoomToastType.textMessageDisable: 0,
    RoomToastType.roomEndByHost: 1,
    RoomToastType.roomNetworkLeave: 2,
  };

  static const Map<int, RoomToastType> mapValue = {
    -1: RoomToastType.none,
    0: RoomToastType.textMessageDisable,
    1: RoomToastType.roomEndByHost,
    2: RoomToastType.roomNetworkLeave,
  };
}

class RoomToastContent {
  RoomToastType toastType = RoomToastType.none;
  String message = '';

  RoomToastContent.empty();

  RoomToastContent(this.toastType, this.message);

  RoomToastContent.fromJson(Map<String, dynamic> json) {
    int typeIntValue = json['type'];
    toastType = RoomToastTypeExtension.mapValue[typeIntValue] as RoomToastType;
    message = json['message'];
  }

  Map<String, dynamic> toJson() =>
      {'type': RoomToastTypeExtension.valueMap[toastType], 'message': message};
}
