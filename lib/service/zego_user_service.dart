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

  Future<int> fetchOnlineRoomUsersNum(String roomID) async {
    var result = await ZIMPlugin.queryRoomOnlineMemberCount(roomID);
    int code = result['errorCode'];
    if (code == 0) {
      totalUsersNum = result['count'];
    }
    notifyListeners();
    return code;
  }

  Future<int> login(ZegoUserInfo info, String token) async {
    localUserInfo = info;
    if (info.userName.isEmpty) {
      localUserInfo.userName = info.userID;
    }
    loginState = LoginState.loginStateLoggingIn;
    notifyListeners();

    // Note: token is generate in native code
    var result = await ZIMPlugin.login(info.userID, info.userName, "");
    int code = result['errorCode'];

    loginState = code != 0
        ? LoginState.loginStateLoginFailed
        : LoginState.loginStateLoggedIn;
    notifyListeners();

    return code;
  }

  Future<int> logout() async {
    var result = await ZIMPlugin.logout();
    notifyListeners();
    return result['errorCode'];
  }

  Future<int> sendInvitation(String userID) async {
    var result = await ZIMPlugin.sendPeerMessage(userID, "", 1);
    notifyListeners();
    return result['errorCode'];
  }

  // TODO@oliveryang
  void setUserRoleForUITest(ZegoRoomUserRole role) {
    localUserInfo.userRole = role;
    notifyListeners();
  }
}
