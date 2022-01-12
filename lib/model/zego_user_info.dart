import 'package:live_audio_room_flutter/model/zego_room_user_role.dart';

/// Class user information.
/// <p>Description: This class contains the user related information.</>
class ZegoUserInfo {
  /// User ID, refers to the user unique ID, can only contains numbers and letters.
  String userId = "";
  /// User name, cannot be null.
  String userName = "";
  /// User role
  ZegoRoomUserRole userRole = ZegoRoomUserRole.roomUserRoleListener;

  ZegoUserInfo.empty();
  ZegoUserInfo(this.userId, this.userName, this.userRole);

  @override
  String toString() {
    return "UserInfo [userId=$userId,userName=$userName,userRole=$userRole]";
  }
}
