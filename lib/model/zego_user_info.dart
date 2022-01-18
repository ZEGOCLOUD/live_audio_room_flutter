import 'package:live_audio_room_flutter/model/zego_room_user_role.dart';

/// Class user information.
/// <p>Description: This class contains the user related information.</>
class ZegoUserInfo {
  /// User ID, refers to the user unique ID, can only contains numbers and letters.
  String userID = "";
  /// User name, cannot be null.
  String userName = "";
  /// User role
  ZegoRoomUserRole userRole = ZegoRoomUserRole.roomUserRoleListener;

  ZegoUserInfo.empty();
  ZegoUserInfo(this.userID, this.userName, this.userRole);

  bool isEmpty() {
    return userID.isEmpty || userName.isEmpty;
  }

  @override
  String toString() {
    return "UserInfo [userId=$userID,userName=$userName,userRole=$userRole]";
  }
}
