enum RoomGiftID {
  fingerHeart,
}

extension RoomGiftIDExtension on RoomGiftID {
  static const valueMap = {
    RoomGiftID.fingerHeart: 0,
  };

  int get value => valueMap[this] ?? -1;
}

class ZegoRoomGift {
  int id = 0;
  String name = '';
  String res = '';

  ZegoRoomGift.empty();

  ZegoRoomGift(this.id, this.name, this.res);
}
