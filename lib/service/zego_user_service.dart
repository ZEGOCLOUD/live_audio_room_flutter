import 'dart:convert';

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

enum ConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

enum ConnectionEvent {
  success,
  activeLogin,
  loginTimeout,
  loginInterrupted,
  kickedOut,
}


typedef LoginCallback = Function(int);

class ZegoUserService extends ChangeNotifier {
  // TODO@oliver update userList on SDK callback and notify changed
  List<ZegoUserInfo> userList = [];
  Map<String, ZegoUserInfo> userDic = Map<String, ZegoUserInfo>();

  ZegoUserInfo localUserInfo = ZegoUserInfo.empty();
  int totalUsersNum = 0;
  LoginState loginState = LoginState.loginStateLoggedOut;

  ZegoUserService() {
    ZIMPlugin.onRoomMemberJoined = _onRoomMemberJoined;
    ZIMPlugin.onRoomMemberLeave = _onRoomMemberLeave;
    ZIMPlugin.onReceiveCustomPeerMessage = _onReceiveCustomPeerMessage;
    ZIMPlugin.onConnectionStateChanged = _onConnectionStateChanged;
  }

  void fetchOnlineRoomUsersWithPage(int page) {
    // TODO@oliver fetch users info and update userList
  }

  Future<int> fetchOnlineRoomUsersNum(String roomID) async {
    var result = await ZIMPlugin.queryRoomOnlineMemberCount(roomID);
    int code = result['errorCode'];
    if (code == 0) {
      totalUsersNum = result['count'];
      notifyListeners();
    }
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
    return result['errorCode'];
  }

  Future<int> sendInvitation(String userID) async {
    var result = await ZIMPlugin.sendPeerMessage(userID, "", 1);
    return result['errorCode'];
  }

  void _onRoomMemberJoined(
      String roomID, List<Map<String, dynamic>> memberList) {
    for (final item in memberList) {
      var member = ZegoUserInfo.formJson(item);
      userList.add(member);
      userDic[member.userID] = member;
    }
    notifyListeners();
  }

  void _onRoomMemberLeave(
      String roomID, List<Map<String, dynamic>> memberList) {
    for (final item in memberList) {
      var member = ZegoUserInfo.formJson(item);
      userList.removeWhere((element) => element.userID == member.userID);
      userDic.removeWhere((key, value) => key == member.userID);
    }
    notifyListeners();
  }


  void _onReceiveCustomPeerMessage(List<Map<String, dynamic>> messageListJson) {
    for (final item in messageListJson) {
      var messageJson = item['message'];
      Map<String, dynamic> messageDic = jsonDecode(messageJson);
      int actionType = messageDic['actionType'];
      if (actionType == 1) {
      }
    }
    notifyListeners();
  }

  void _onConnectionStateChanged(int state, int event) {

    notifyListeners();
  }

}
