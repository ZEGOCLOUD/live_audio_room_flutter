import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_provider_utilities/flutter_provider_utilities.dart';

import 'package:live_audio_room_flutter/model/zego_room_user_role.dart';
import 'package:live_audio_room_flutter/model/zego_user_info.dart';
import 'package:live_audio_room_flutter/plugin/ZIMPlugin.dart';
import 'package:live_audio_room_flutter/constants/zego_constant.dart';
import 'package:live_audio_room_flutter/service/zego_room_manager.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:live_audio_room_flutter/common/room_info_content.dart';

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
typedef MemberOfflineCallback = VoidCallback;
typedef MemberChangeCallback = Function(List<ZegoUserInfo>);

class ZegoUserService extends ChangeNotifier with MessageNotifierMixin {
  MemberOfflineCallback? userOfflineCallback;
  List<ZegoUserInfo> userList = [];
  Map<String, ZegoUserInfo> userDic = <String, ZegoUserInfo>{};

  ZegoUserInfo localUserInfo = ZegoUserInfo.empty();
  int totalUsersNum = 0;
  LoginState loginState = LoginState.loginStateLoggedOut;
  Set<String> _preSpeakerSet = {}; //Prevent frequent updates
  final Set<MemberChangeCallback> _memberJoinedCallbackSet = {};
  final Set<MemberChangeCallback> _memberLeaveCallbackSet = {};

  ZegoUserService() {
    ZIMPlugin.onRoomMemberJoined = _onRoomMemberJoined;
    ZIMPlugin.onRoomMemberLeave = _onRoomMemberLeave;
    ZIMPlugin.onReceiveCustomPeerMessage = _onReceiveCustomPeerMessage;
    ZIMPlugin.onConnectionStateChanged = _onConnectionStateChanged;
  }

  registerMemberJoinCallback(MemberChangeCallback callback) {
    _memberJoinedCallbackSet.add(callback);
  }

  unregisterMemberJoinCallback(MemberChangeCallback callback) {
    _memberJoinedCallbackSet.remove(callback);
  }

  registerMemberLeaveCallback(MemberChangeCallback callback) {
    _memberLeaveCallbackSet.add(callback);
  }

  unregisterMemberLeaveCallback(MemberChangeCallback callback) {
    _memberJoinedCallbackSet.remove(callback);
  }

  onRoomLeave() {
    _preSpeakerSet.clear();
    userList.clear();
    userDic.clear();
    // We need to reuse local user id after leave room
    localUserInfo.userRole = ZegoRoomUserRole.roomUserRoleListener;
    totalUsersNum = 0;
    loginState = LoginState.loginStateLoggedOut;
  }

  onRoomEnter() {
    _updateUserRole({});
  }

  ZegoUserInfo getUserByID(String userID) {
    var userInfo = userDic[userID] ?? ZegoUserInfo.empty();
    return userInfo.clone();
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

    if (code != 0) {
      localUserInfo = ZegoUserInfo.empty();
      loginState = LoginState.loginStateLoggedIn;
    } else {
      loginState = LoginState.loginStateLoginFailed;
    }
    notifyListeners();

    return code;
  }

  Future<int> logout() async {
    var result = await ZIMPlugin.logout();
    localUserInfo = ZegoUserInfo.empty();
    loginState = LoginState.loginStateLoggedOut;
    notifyListeners();
    return result['errorCode'];
  }

  Future<int> sendInvitation(String userID) async {
    var result = await ZIMPlugin.sendPeerMessage(userID, "", 1);
    return result['errorCode'];
  }

  void _onRoomMemberJoined(
      String roomID, List<Map<String, dynamic>> memberList) {
    var userInfoList = <ZegoUserInfo>[];
    for (final item in memberList) {
      var member = ZegoUserInfo.formJson(item);
      userList.add(member);
      userDic[member.userID] = member;

      if (member.userID.isNotEmpty && localUserInfo.userID != member.userID) {
        userInfoList.add(member.clone());
      }
    }
    for (final callback in _memberJoinedCallbackSet) {
      callback([...userInfoList]);
    }
    notifyListeners();
  }

  void _onRoomMemberLeave(
      String roomID, List<Map<String, dynamic>> memberList) {
    var userInfoList = <ZegoUserInfo>[];
    for (final item in memberList) {
      var member = ZegoUserInfo.formJson(item);
      userList.removeWhere((element) => element.userID == member.userID);
      userDic.removeWhere((key, value) => key == member.userID);

      if (member.userID.isNotEmpty && localUserInfo.userID != member.userID) {
        userInfoList.add(member.clone());
      }
      for (final callback in _memberLeaveCallbackSet) {
        callback([...userInfoList]);
      }
    }
    notifyListeners();
  }

  void _onReceiveCustomPeerMessage(List<Map<String, dynamic>> messageListJson) {
    for (final item in messageListJson) {
      var messageJson = item['message'];
      Map<String, dynamic> messageDic = jsonDecode(messageJson);
      int actionType = messageDic['actionType'];
      if (actionType == 1) {
        // receive invitation
        RoomInfoContent toastContent = RoomInfoContent.empty();
        toastContent.toastType = RoomInfoType.roomHostInviteToSpeak;
        notifyInfo(json.encode(toastContent.toJson()));
      }
    }
    notifyListeners();
  }

  void _onConnectionStateChanged(int state, int event) {
    zimConnectionState? connectionState =
        zimConnectionStateExtension.mapValue[state];
    zimConnectionEvent? connectionEvent =
        zimConnectionEventExtension.mapValue[event];

    if (connectionState == zimConnectionState.zimConnectionStateReconnecting &&
        connectionEvent ==
            zimConnectionEvent.zimConnectionEventLoginInterrupted) {
      //  temp network broken
      RoomInfoContent toastContent = RoomInfoContent.empty();
      toastContent.toastType = RoomInfoType.roomNetworkTempBroken;
      notifyInfo(json.encode(toastContent.toJson()));
    } else if (connectionState ==
            zimConnectionState.zimConnectionStateConnected &&
        connectionEvent == zimConnectionEvent.zimConnectionEventSuccess) {
      //  reconnected after temp network broken
      RoomInfoContent toastContent = RoomInfoContent.empty();
      toastContent.toastType = RoomInfoType.roomNetworkReconnected;
      notifyInfo(json.encode(toastContent.toJson()));
    } else if (connectionState ==
            zimConnectionState.zimConnectionStateDisconnected &&
        connectionEvent == zimConnectionEvent.zimConnectionEventKickedOut) {
      //  kick out
      RoomInfoContent toastContent = RoomInfoContent.empty();
      toastContent.toastType = RoomInfoType.loginUserKickOut;
      notifyInfo(json.encode(toastContent.toJson()));
      if (userOfflineCallback != null) {
        userOfflineCallback!();
      }
    } else if (connectionState ==
            zimConnectionState.zimConnectionStateDisconnected &&
        connectionEvent == zimConnectionEvent.zimConnectionEventLoginTimeout) {
      //  connect timeout
      RoomInfoContent toastContent = RoomInfoContent.empty();
      toastContent.toastType = RoomInfoType.roomNetworkReconnectedTimeout;
      notifyInfo(json.encode(toastContent.toJson()));
      if (userOfflineCallback != null) {
        userOfflineCallback!();
      }
    }

    notifyListeners();
  }

  void updateSpeakerSet(Set<String> speakerSet) {
    if (setEquals(_preSpeakerSet, speakerSet)) {
      return;
    }
    _preSpeakerSet = {...speakerSet};
    _updateUserRole(speakerSet);
  }

  void _updateUserRole(Set<String> speakerList) {
    var hostID = ZegoRoomManager.shared.roomService.roomInfo.hostID;
    // Leave room or init
    if (hostID.isEmpty) {
      return;
    }
    // Update local user role
    if (hostID == localUserInfo.userID) {
      localUserInfo.userRole = ZegoRoomUserRole.roomUserRoleHost;
    } else if (speakerList.contains(localUserInfo.userID)) {
      localUserInfo.userRole = ZegoRoomUserRole.roomUserRoleSpeaker;
    } else {
      localUserInfo.userRole = ZegoRoomUserRole.roomUserRoleListener;
    }
    for (var user in userList) {
      if (user.userID == hostID) {
        user.userRole = ZegoRoomUserRole.roomUserRoleHost;
      } else if (speakerList.contains(user.userID)) {
        user.userRole = ZegoRoomUserRole.roomUserRoleSpeaker;
      } else {
        user.userRole = ZegoRoomUserRole.roomUserRoleListener;
      }
    }
    notifyListeners();
  }
}
