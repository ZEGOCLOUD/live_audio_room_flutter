import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:async/async.dart';

typedef ZegoRoomCallback = Function(int);

class ZegoGiftService extends ChangeNotifier {
  String giftSender = "";
  String giftName = "";
  List<String> giftReceivers = [];
  late RestartableTimer _timer;

  ZegoGiftService() {
    _timer = RestartableTimer(const Duration(seconds: 10), () {
      giftSender = "";
      giftName = "";
      giftReceivers = [];
      notifyListeners();
    });
    // TODO@larry binding delegate to SDK and call notifyListeners() while data changed.
  }

  void sendGift(
      String giftID, List<String> toUserList, ZegoRoomCallback? callback) {
    // TODO@larry call SDK and update data in delegate while callback with succeed code.
    // Below code just for UI test, Please map gitID to gift name and map userID to user name.
    giftName = giftID;
    giftReceivers = toUserList;
    giftSender = "Some One";
    notifyListeners();
    _timer.reset();
  }
}
