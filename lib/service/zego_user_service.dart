import 'package:flutter/foundation.dart';
import 'package:live_audio_room_flutter/model/zego_room_user_role.dart';
import 'package:live_audio_room_flutter/model/zego_user_info.dart';
import 'package:live_audio_room_flutter/plugin/ZIMPlugin.dart';

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

  void fetchOnlineRoomUsersNum(String roomID) {
    int result = ZIMPlugin.queryRoomOnlineMemberCount(roomID);
    totalUsersNum = 0;
    notifyListeners();
  }

  void login(ZegoUserInfo info, LoginCallback? callback) {
    localUserInfo = info;
    if (info.userName.isEmpty) {
      localUserInfo.userName = info.userID;
    }
    loginState = LoginState.loginStateLoggingIn;
    notifyListeners();
    // Note: token is generate in native code
    Map result = ZIMPlugin.login(info.userID, info.userName, "");
    var errorCode = result['errorCode'];
    if (callback != null) {
      callback(errorCode);
    }
    // TODO@oliver call in SDK async callback
    loginState = errorCode != 0 ? LoginState.loginStateLoginFailed : LoginState.loginStateLoggedIn;
    notifyListeners();

    // TODO@oliver FOR UI TEST ONLY
    userList.add(localUserInfo);
    notifyListeners();
  }

  void logout() {
    ZIMPlugin.logout();
    loginState = LoginState.loginStateLoggedOut;
    notifyListeners();
  }

  void sendInvitation(String userID) {
    ZIMPlugin.sendPeerMessage(userID, "", 1);
  }


  // TODO@oliveryang
  void setUserRoleForUITest(ZegoRoomUserRole role) {
    localUserInfo.userRole = role;
    notifyListeners();
  }

}
