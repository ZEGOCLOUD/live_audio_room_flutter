import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:live_audio_room_flutter/plugin/zim_plugin.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:live_audio_room_flutter/service/zego_room_manager.dart';
import 'package:live_audio_room_flutter/common/room_info_content.dart';
import 'package:live_audio_room_flutter/constants/zego_room_constant.dart';
import 'package:live_audio_room_flutter/model/zego_room_info.dart';
import 'package:live_audio_room_flutter/constants/zim_error_code.dart';

typedef RoomCallback = Function(int);
typedef RoomLeaveCallback = VoidCallback;
typedef RoomEnterCallback = VoidCallback;

/// Class LiveAudioRoom information management.
/// <p>Description: This class contains the room information management logics, such as the logic of create a room, join
/// a room, leave a room, disable the text chat in room, etc.</>
class ZegoRoomService extends ChangeNotifier {
  /// Room information, it will be assigned after join the room successfully. And it will be updated synchronously when
  /// the room status updates.
  RoomInfo roomInfo = RoomInfo('', '', '');
  RoomLeaveCallback? roomLeaveCallback;
  RoomEnterCallback? roomEnterCallback;

  String notifyInfo = '';

  void clearNotifyInfo() {
    notifyInfo = '';
  }

  ZegoRoomService() {
    ZIMPlugin.onRoomInfoUpdate = _onRoomInfoUpdate;
    ZIMPlugin.onRoomStateChanged = _onRoomStateChanged;
  }

  onRoomLeave() {}

  onRoomEnter() {}

  String get _localUserID {
    return ZegoRoomManager.shared.userService.localUserInfo.userID;
  }

  String get _localUserName {
    return ZegoRoomManager.shared.userService.localUserInfo.userName;
  }

  /// Create a room.
  /// <p>Description: This method can be used to create a room. The room creator will be the Host by default when the
  /// room is created successfully.</>
  /// <p>Call this method at: After user logs in </>
  ///
  /// @param roomID   roomID refers to the room ID, the unique identifier of the room. This is required to join a room
  ///                 and cannot be null.
  /// @param roomName roomName refers to the room name. This is used for display in the room and cannot be null.
  /// @param token    token refers to the authentication token. To get this, see the documentation:
  ///                 https://doc-en.zego.im/article/11648
  Future<int> createRoom(String roomID, String roomName, String token) async {
    var result = await ZIMPlugin.createRoom(roomID, roomName, _localUserID, 8);
    var code = result['errorCode'];
    if (ZIMErrorCodeExtension.valueMap[zimErrorCode.success] == code) {
      var result = await ZIMPlugin.queryRoomAllAttributes(roomID);
      var attributesResult = result['roomAttributes'];
      var roomDic = attributesResult['room_info'];
      _updateRoomInfo(RoomInfo.fromJson(jsonDecode(roomDic)));
      _loginRtcRoom();
      notifyListeners();
    }
    return code;
  }

  /// Join a room.
  /// <p>Description: This method can be used to join a room, the room must be an existing room.</>
  /// <p>Call this method at: After user logs in</>
  ///
  /// @param roomID   refers to the ID of the room you want to join, and cannot be null.
  /// @param token    token refers to the authentication token. To get this, see the documentation:
  ///                 https://doc-en.zego.im/article/11648
  Future<int> joinRoom(String roomID, String token) async {
    var joinResult = await ZIMPlugin.joinRoom(roomID);
    var code = joinResult['errorCode'];
    if (ZIMErrorCodeExtension.valueMap[zimErrorCode.success] == code) {
      var result = await ZIMPlugin.queryRoomAllAttributes(roomID);

      var attributesResult = result['roomAttributes'];
      var roomDic = attributesResult['room_info'];
      if (roomDic == null) {
        // room has end
        RoomInfoContent toastContent = RoomInfoContent.empty();
        toastContent.toastType =
            RoomInfoType.roomEndByHost; //  clear in receiver
        notifyInfo = json.encode(toastContent.toJson());
      } else {
        var roomInfoJson = Map<String, dynamic>.from(jsonDecode(roomDic));
        var roomInfoObj = RoomInfo.fromJson(jsonDecode(roomDic));
        _onRoomInfoUpdate(roomInfoObj.roomID, roomInfoJson);

        _loginRtcRoom();
      }

      notifyListeners();
    }
    return code;
  }

  /// Leave the room.
  /// <p>Description: This method can be used to leave the room you joined. The room will be ended when the Host
  /// leaves, and all users in the room will be forced to leave the room.</>
  /// <p>Call this method at: After joining a room</>
  Future<int> leaveRoom() async {
    var roomId = roomInfo.roomID;

    await ZegoExpressEngine.instance.stopSoundLevelMonitor();
    await ZegoExpressEngine.instance.stopPublishingStream();
    await ZegoExpressEngine.instance.logoutRoom(roomId);

    var result = await ZIMPlugin.leaveRoom(roomId);

    roomInfo = RoomInfo('', '', '');

    var code = result['errorCode'];
    return code;
  }

  /// Disable text chat in the room.
  /// <p>Description: This method can be used to disable the text chat in the room.</>
  /// <p>Call this method at: After joining a room</>
  ///
  /// @param disable  refers to the parameter that whether to disable the text chat. To disable the text chat, set it
  ///                 to [true]; To allow the text chat, set it to [false].
  Future<int> disableTextMessage(bool disable) async {
    var targetRoomInfo = roomInfo.clone();
    targetRoomInfo.isTextMessageDisable = disable;
    _updateRoomInfo(targetRoomInfo);

    var json = jsonEncode(roomInfo);
    var map = {'room_info': json};
    var mapJson = jsonEncode(map);
    var result =
        await ZIMPlugin.setRoomAttributes(roomInfo.roomID, mapJson, true);
    int code = result['errorCode'];
    if (ZIMErrorCodeExtension.valueMap[zimErrorCode.success] != code) {
      //  restore value
      var targetRoomInfo = roomInfo.clone();
      targetRoomInfo.isTextMessageDisable = !disable;
      _updateRoomInfo(targetRoomInfo);
    }

    notifyListeners();
    return code;
  }

  Future<void> _onRoomStateChanged(int state, int event) async {
    var autoClearNotifyInfo = true;

    ZimRoomState? roomState = ZimRoomStateExtension.mapValue[state];
    zimRoomEvent? roomEvent = ZIMRoomEventExtension.mapValue[event];

    if (roomState == ZimRoomState.zimRoomStateDisconnected &&
        roomInfo.roomID.isNotEmpty) {
      if (roomLeaveCallback != null) {
        roomLeaveCallback!();
      }

      if (roomEvent == zimRoomEvent.zimRoomEventEnterFailed) {
        // network error leave room
        RoomInfoContent toastContent = RoomInfoContent.empty();
        toastContent.toastType = RoomInfoType.roomNetworkLeave;
        notifyInfo = json.encode(toastContent.toJson());
        autoClearNotifyInfo = false; //  clear in receiver
      }
    } else if (roomState == ZimRoomState.zimRoomStateConnected &&
        roomEvent == zimRoomEvent.zimRoomEventSuccess) {
      //  sync room
      var result = await ZIMPlugin.queryRoomAllAttributes(roomInfo.roomID);
      var attributesResult = result['roomAttributes'];
      var roomDic = attributesResult['room_info'];
      if (roomDic != null) {
        _updateRoomInfo(RoomInfo.fromJson(jsonDecode(roomDic)));
        if (roomEnterCallback != null) {
          roomEnterCallback!();
        }
      }

      // for hide loading if network temp broke before
      RoomInfoContent toastContent = RoomInfoContent.empty();
      toastContent.toastType = RoomInfoType.roomNetworkReconnected;
      notifyInfo = json.encode(toastContent.toJson());
      autoClearNotifyInfo = false; //  clear in receiver
    }

    notifyListeners();

    if (autoClearNotifyInfo) {
      Future.delayed(const Duration(milliseconds: 500), () async {
        notifyInfo = '';
      });
    }
  }

  void _onRoomInfoUpdate(String roomID, Map<String, dynamic> roomInfoJson) {
    // room has end by host
    if (roomInfoJson.keys.isEmpty) {
      RoomInfoContent toastContent = RoomInfoContent.empty();
      toastContent.toastType = RoomInfoType.roomEndByHost; //  clear in receiver
      notifyInfo = json.encode(toastContent.toJson());

      if (_localUserID != roomInfo.hostID) {
        leaveRoom();
      }
    } else {
      _updateRoomInfo(RoomInfo.fromJson(roomInfoJson));
      if (roomEnterCallback != null) {
        roomEnterCallback!();
      }
    }

    notifyListeners();
  }

  Future<void> _loginRtcRoom() async {
    var user = ZegoUser(_localUserID, _localUserName);
    var config = ZegoRoomConfig.defaultConfig();
    var result = await ZIMPlugin.getRTCToken(roomInfo.roomID, _localUserID);
    config.token = result["token"];
    config.maxMemberCount = 0;
    ZegoExpressEngine.instance.loginRoom(roomInfo.roomID, user, config: config);
    var soundConfig = ZegoSoundLevelConfig(1000, false);
    ZegoExpressEngine.instance.startSoundLevelMonitor(config: soundConfig);
  }

  void _updateRoomInfo(RoomInfo updatedRoomInfo) {
    var oldRoomInfo = roomInfo.clone();
    roomInfo = updatedRoomInfo.clone();

    RoomInfoContent toastContent = RoomInfoContent.empty();
    if (oldRoomInfo.isTextMessageDisable != roomInfo.isTextMessageDisable) {
      toastContent.toastType =
          RoomInfoType.textMessageDisable; //  clear in receiver
      toastContent.message = roomInfo.isTextMessageDisable.toString();

      notifyInfo = json.encode(toastContent.toJson());
      notifyListeners();
    }
  }
}
