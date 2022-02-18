import 'package:flutter/foundation.dart';

import 'package:live_audio_room_flutter/plugin/zim_plugin.dart';

import 'package:live_audio_room_flutter/service/zego_room_manager.dart';

import 'package:live_audio_room_flutter/model/zego_user_info.dart';
import 'package:live_audio_room_flutter/model/zego_text_message.dart';
import 'package:live_audio_room_flutter/constants/zim_error_code.dart';

typedef ZegoRoomCallback = Function(int);

/// Class IM message management.
/// <p>Description: This class contains the logics of the IM messages management, such as send or receive messages.</>
class ZegoMessageService extends ChangeNotifier {
  List<ZegoTextMessage> messageList = [];
  String memberJoinedText = '';
  String memberLeaveText = '';

  ZegoMessageService() {
    ZIMPlugin.onReceiveTextRoomMessage = _onReceiveTextMessage;
  }

  onRoomLeave() {
    messageList.clear();
    memberJoinedText = '';
    memberLeaveText = '';
  }

  onRoomEnter() {}

  String get _localUserID {
    return ZegoRoomManager.shared.userService.localUserInfo.userID;
  }

  /// Send IM text message.
  /// <p>Description: This method can be used to send IM text message, and all users in the room will receive the
  /// message notification.</>
  /// <p>Call this method at:  After joining the room</>
  ///
  /// @param text     refers to the text message content, which is limited to 1kb.
  /// @param userID
  /// @param message
  Future<int> sendTextMessage(
      String roomID, String userID, String message) async {
    var result = await ZIMPlugin.sendRoomMessage(roomID, message, false);
    int code = result['errorCode'];
    if (ZIMErrorCodeExtension.valueMap[zimErrorCode.success] == code) {
      var msg = ZegoTextMessage();
      msg.message = message;
      msg.userID = userID;
      msg.timestamp = DateTime.now().millisecondsSinceEpoch;
      messageList.add(msg);
      notifyListeners();
    }
    return code;
  }

  void setTranslateTexts(String memberJoinedText, String memberLeaveText) {
    this.memberJoinedText = memberJoinedText;
    this.memberLeaveText = memberLeaveText;
  }

  void _onReceiveTextMessage(
      String roomID, List<Map<String, dynamic>> messageListJson) {
    for (final item in messageListJson) {
      var message = ZegoTextMessage.formJson(item);
      messageList.add(message);
    }
    notifyListeners();
  }

  void onRoomMemberJoined(List<ZegoUserInfo> members) {
    if (members.isEmpty) {
      return;
    }

    if (members.first.userID == _localUserID) {
      return; //  users before is current user join
    }

    if (memberJoinedText.isEmpty) {
      return;
    }

    for (var member in members) {
      if (member.userID.isEmpty || member.userName.isEmpty) {
        return;
      }

      ZegoTextMessage message = ZegoTextMessage();
      message.message = memberJoinedText.replaceAll('%@', member.userName);
      messageList.add(message);
    }

    notifyListeners();
  }

  void onRoomMemberLeave(List<ZegoUserInfo> members) {
    if (memberLeaveText.isEmpty) {
      return;
    }

    for (var member in members) {
      if (member.userID.isEmpty || member.userName.isEmpty) {
        return;
      }

      ZegoTextMessage message = ZegoTextMessage();
      message.message = memberLeaveText.replaceAll('%@', member.userName);
      messageList.add(message);
    }

    notifyListeners();
  }
}
