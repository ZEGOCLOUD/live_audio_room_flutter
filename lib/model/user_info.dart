import 'package:flutter/foundation.dart';

enum RoomUserRole {
  roomUserRoleListener,
  roomUserRoleSpeaker,
  roomUserRoleHost,
}

class UserInfo {
  String userId = "";
  String userName = "";
  RoomUserRole userRole = RoomUserRole.roomUserRoleListener;
}
