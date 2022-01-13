import 'package:flutter/foundation.dart';
import 'package:live_audio_room_flutter/model/zego_room_user_role.dart';
import 'package:live_audio_room_flutter/model/zego_user_info.dart';

enum LoginState {
  loginStateLoggedOut,
  loginStateLoggingIn,
  loginStateLoggedIn,
  loginStateLoginFailed,
}

typedef LoginCallback = Function(int);

class ZegoUserService extends ChangeNotifier {
  // TODO@oliver update userList on SDK callback and notify changed
  late List<ZegoUserInfo> userList = [
    ZegoUserInfo("111", "Host Name", ZegoRoomUserRole.roomUserRoleHost),
    ZegoUserInfo("222", "Speaker Name", ZegoRoomUserRole.roomUserRoleHost),
  ]; // Init list for UI test
  late ZegoUserInfo localUserInfo;
  late Map<String, ZegoUserInfo> userDic;
  late String token;
  int totalUsersNum = 0;
  LoginState loginState = LoginState.loginStateLoggedOut;

  ZegoUserService() {
    // TODO@larry binding delegate to SDK and call notifyListeners() while data changed.
  }

  void fetchOnlineRoomUsersWithPage(int page) {
    // TODO@oliver fetch users info and update userList
    notifyListeners();
  }

  void fetchOnlineRoomUsersNum() {
    // TODO@oliver fetch users info and count the num
    totalUsersNum = 0;
    notifyListeners();
  }

  void login(ZegoUserInfo info, String token, LoginCallback? callback) {
    localUserInfo = info;
    loginState = LoginState.loginStateLoggingIn;
    notifyListeners();
    if (callback != null) {
      // TODO@oliver call in SDK real callback
      loginState = LoginState.loginStateLoggedIn;
      callback(0);
    }
    // TODO@oliver notify in SDK callback
    notifyListeners();
  }

  void logout() {
    loginState = LoginState.loginStateLoggedOut;
    notifyListeners();
  }
}
