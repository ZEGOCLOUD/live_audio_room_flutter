enum RoomToastType {
  none,
  textMessageDisable,
}

extension RoomToastTypeExtension on RoomToastType {
  static const valueMap = {
    RoomToastType.none: -1,
    RoomToastType.textMessageDisable: 0,
  };

  int get value => valueMap[this] ?? -1;
}

class RoomToastContent {
  RoomToastType toastType = RoomToastType.none;
  String message = '';

  RoomToastContent.empty();

  RoomToastContent(this.toastType, this.message);

  RoomToastContent.fromJson(Map<String, dynamic> json) {
    int typeIntValue = json['type'];
    toastType = RoomToastType.values[typeIntValue];
    message = json['message'];
  }

  Map<String, dynamic> toJson() =>
      {'type': RoomToastTypeExtension.valueMap[toastType], 'message': message};
}
