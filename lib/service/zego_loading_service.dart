import 'package:flutter/foundation.dart';

class ZegoLoadingService extends ChangeNotifier {
  String _loadingText = "";

  onRoomLeave() {
    _loadingText = "";
  }

  onRoomEnter() {}

  void updateLoadingText(String text) {
    _loadingText = text;
    notifyListeners();
  }

  String loadingText() {
    return _loadingText;
  }
}
