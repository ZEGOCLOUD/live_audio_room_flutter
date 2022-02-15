import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:live_audio_room_flutter/plugin/zim_plugin.dart';

import 'package:live_audio_room_flutter/constants/zego_connection_constant.dart';
import 'package:live_audio_room_flutter/constants/zego_custom_command_constant.dart';
import 'package:live_audio_room_flutter/model/zego_room_user_role.dart';
import 'package:live_audio_room_flutter/model/zego_user_info.dart';
import 'package:live_audio_room_flutter/service/zego_room_manager.dart';
import 'package:live_audio_room_flutter/common/room_info_content.dart';
import 'package:live_audio_room_flutter/constants/zim_error_code.dart';

enum LoginState {
  loginStateLoggedOut,
  loginStateLoggingIn,
  loginStateLoggedIn,
  loginStateLoginFailed,
}

typedef LoginCallback = Function(int);
typedef MemberOfflineCallback = VoidCallback;
typedef MemberChangeCallback = Function(List<ZegoUserInfo>);

/// Class user information management.
/// <p>Description: This class contains the user information management logics, such as the logic of log in, log out,
/// get the logged-in user info, get the in-room user list, and add co-hosts, etc. </>
class ZegoUserService extends ChangeNotifier {
  MemberOfflineCallback? userOfflineCallback;

  /// In-room user list, can be used when displaying the user list in the room.
  List<ZegoUserInfo> userList = [];

  /// In-room user dictionary,  can be used to update user information.¬
  Map<String, ZegoUserInfo> userDic = <String, ZegoUserInfo>{};

  /// The local logged-in user information.
  ZegoUserInfo localUserInfo = ZegoUserInfo.empty();
  int totalUsersNum = 0;
  LoginState loginState = LoginState.loginStateLoggedOut;
  Set<String> _preSpeakerSet = {}; //Prevent frequent updates
  final Set<MemberChangeCallback> _memberJoinedCallbackSet = {};
  final Set<MemberChangeCallback> _memberLeaveCallbackSet = {};

  String notifyInfo = '';

  void _clearNotifyInfo() {
    Future.delayed(const Duration(milliseconds: 500), () async {
      notifyInfo = '';
    });
  }

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
    _updateUserRole(_preSpeakerSet);
  }

  ZegoUserInfo getUserByID(String userID) {
    var userInfo = userDic[userID] ?? ZegoUserInfo.empty();
    return userInfo.clone();
  }

  Future<int> fetchOnlineRoomUsersNum(String roomID) async {
    var result = await ZIMPlugin.queryRoomOnlineMemberCount(roomID);
    int code = result['errorCode'];
    if (ZIMErrorCodeExtension.valueMap[zimErrorCode.success] == code) {
      totalUsersNum = result['count'];
      notifyListeners();
    }
    return code;
  }

  /// User to log in.
  /// <p>Description: Call this method with user ID and username to log in to the LiveAudioRoom service.</>
  /// <p>Call this method at: After the SDK initialization</>
  ///
  /// @param userInfo refers to the user information. You only need to enter the user ID and username.
  /// @param token    refers to the authentication token. To get this, refer to the documentation:
  ///                 https://doc-en.zego.im/article/11648
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

    if (ZIMErrorCodeExtension.valueMap[zimErrorCode.success] != code) {
      localUserInfo = ZegoUserInfo.empty();
      loginState = LoginState.loginStateLoggedIn;
    } else {
      loginState = LoginState.loginStateLoginFailed;
    }
    notifyListeners();

    return code;
  }

  /// User to log out.
  /// <p>Description: This method can be used to log out from the current user account.</>
  /// <p>Call this method at: After the user login</>
  Future<int> logout() async {
    var result = await ZIMPlugin.logout();
    localUserInfo = ZegoUserInfo.empty();
    loginState = LoginState.loginStateLoggedOut;
    notifyListeners();
    return result['errorCode'];
  }

  /// Invite users to speak .
  /// <p>Description: This method can be called to invite users to take a speaker seat to speak, and the invitee will
  /// receive an invitation.</>
  /// <p>Call this method at:  After joining a room</>
  ///
  /// @param userID   refers to the ID of the user that you want to invite
  Future<int> sendInvitation(String userID) async {
    var content = "";
    if (Platform.isAndroid) {
      content = "{}";
    }
    var result = await ZIMPlugin.sendPeerMessage(userID, content, 1);
    return result['errorCode'];
  }

  void _onRoomMemberJoined(
      String roomID, List<Map<String, dynamic>> memberList) {
    var userInfoList = <ZegoUserInfo>[];
    for (final item in memberList) {
      var member = ZegoUserInfo.formJson(item);
      if (userDic.containsKey(member.userID)) {
        continue; //  duplicate user
      }

      userList.add(member);
      userDic[member.userID] = member;

      if (member.userID.isNotEmpty && localUserInfo.userID != member.userID) {
        userInfoList.add(member.clone());
      }
    }

    _updateUserRole(_preSpeakerSet); //  memberList hasn't role attribute

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
      if (zegoCustomCommandType.invitation ==
          ZegoCustomCommandTypeExtension.mapValue[actionType]) {
        // receive invitation
        RoomInfoContent toastContent = RoomInfoContent.empty();
        toastContent.toastType = RoomInfoType.roomHostInviteToSpeak;
        notifyInfo = json.encode(toastContent.toJson());
      }
    }
    notifyListeners();
    _clearNotifyInfo();
  }

  void _onConnectionStateChanged(int state, int event) {
    zimConnectionState? connectionState =
        ZIMConnectionStateExtension.mapValue[state];
    zimConnectionEvent? connectionEvent =
        ZIMConnectionEventExtension.mapValue[event];

    if (connectionState == zimConnectionState.zimConnectionStateReconnecting &&
        connectionEvent ==
            zimConnectionEvent.zimConnectionEventLoginInterrupted) {
      //  temp network broken
      RoomInfoContent toastContent = RoomInfoContent.empty();
      toastContent.toastType = RoomInfoType.roomNetworkTempBroken;
      notifyInfo = json.encode(toastContent.toJson());
    } else if (connectionState ==
            zimConnectionState.zimConnectionStateConnected &&
        connectionEvent == zimConnectionEvent.zimConnectionEventSuccess) {
      //  reconnected after temp network broken
      RoomInfoContent toastContent = RoomInfoContent.empty();
      toastContent.toastType = RoomInfoType.roomNetworkReconnected;
      notifyInfo = json.encode(toastContent.toJson());
    } else if (connectionState ==
            zimConnectionState.zimConnectionStateDisconnected &&
        connectionEvent == zimConnectionEvent.zimConnectionEventKickedOut) {
      //  kick out
      RoomInfoContent toastContent = RoomInfoContent.empty();
      toastContent.toastType = RoomInfoType.loginUserKickOut;
      notifyInfo = json.encode(toastContent.toJson());
      if (userOfflineCallback != null) {
        userOfflineCallback!();
      }
    } else if (connectionState ==
            zimConnectionState.zimConnectionStateDisconnected &&
        connectionEvent == zimConnectionEvent.zimConnectionEventLoginTimeout) {
      //  connect timeout
      RoomInfoContent toastContent = RoomInfoContent.empty();
      toastContent.toastType = RoomInfoType.roomNetworkReconnectedTimeout;
      notifyInfo = json.encode(toastContent.toJson());
      if (userOfflineCallback != null) {
        userOfflineCallback!();
      }
    }

    notifyListeners();
    _clearNotifyInfo();
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
