import 'package:flutter/foundation.dart';
import 'package:live_audio_room_flutter/model/user_info.dart';

enum LoginState {
  loginStateLoggedOut,
  loginStateLoggingIn,
  loginStateLoggedIn,
  loginStateLoginFailed,
}



typedef LoginCallback = Function(int);

class UserService extends ChangeNotifier {
  // TODO@oliver update userList on SDK callback and notify changed
  late List<UserInfo> userList;
  late UserInfo localUserInfo;
  late Map<String, UserInfo> userDic;
  late String token;
  int totalUsersNum = 0;
  LoginState loginState = LoginState.loginStateLoggedOut;

  void fetchOnlineRoomUsersWithPage(int page) {
    // TODO@oliver fetch users info and update userList
    notifyListeners();
  }

  void fetchOnlineRoomUsersNum() {
    // TODO@oliver fetch users info and count the num
    totalUsersNum = 0;
    notifyListeners();
  }

  void login(UserInfo info, String token, LoginCallback? callback) {
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
