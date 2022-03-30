import 'package:flutter/foundation.dart';

import '../../plugin/zim_plugin.dart';

import '../../service/zego_room_manager.dart';

import '../../model/zego_user_info.dart';
import '../../model/zego_text_message.dart';
import '../../constants/zim_error_code.dart';

typedef ZegoRoomCallback = Function(int);

/// Class IM message management.
/// <p>Description: This class contains the logics of the IM messages management, such as send or receive messages.</>
class ZegoMessageService extends ChangeNotifier {
  // Current room message list
  List<ZegoTextMessage> messageList = [];
  // Data of <fromUserID, MessageList>, which contains the text message you received
  Map<String, List<ZegoTextMessage>> textPeerMessageReceivedList = {};
  // Data of <toUserID, MessageList>, which contains the text message you has been sent
  Map<String, List<ZegoTextMessage>> textPeerMessageSentList = {};
  String memberJoinedText = '';
  String memberLeaveText = '';

  ZegoMessageService() {
    ZIMPlugin.onReceiveTextRoomMessage = _onReceiveTextRoomMessage;
    ZIMPlugin.onReceiveTextPeerMessage = _onReceiveTextPeerMessage;
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

  /// Send IM text message to specific user.
  /// <p>Description: This method can be used to send IM text message to specific user, and the user with "toUserID" will receive the
  /// message notification.</>
  /// <p>Call this method at:  After user login</>
  ///
  /// @param toUserID the user's ID which you are trying to send message to.
  /// @param message refers to the text message content, which is limited to 1kb.
  Future<int> sendTextPeerMessage(String toUserID, String message) async {
    var result = await ZIMPlugin.sendPeerMessage(toUserID, message, false);
    int code = result['errorCode'];
    var timestamp = result['timestamp'];
    var messageID = result['messageID'];
    if (ZIMErrorCodeExtension.valueMap[zimErrorCode.success] == code) {
      var msg = ZegoTextMessage();
      msg.message = message;
      msg.userID = toUserID;
      msg.timestamp = timestamp;
      msg.messageID = messageID;
      textPeerMessageSentList[toUserID]?.add(msg);
      notifyListeners();
    }
    return code;
  }

  void setTranslateTexts(String memberJoinedText, String memberLeaveText) {
    this.memberJoinedText = memberJoinedText;
    this.memberLeaveText = memberLeaveText;
  }

  void _onReceiveTextRoomMessage(
      String roomID, List<Map<String, dynamic>> messageListJson) {
    for (final item in messageListJson) {
      var message = ZegoTextMessage.formJson(item);
      messageList.add(message);
    }
    notifyListeners();
  }

  void _onReceiveTextPeerMessage(
      List<Map<String, dynamic>> messageListJson, String fromUserID) {
    for (final item in messageListJson) {
      var message = ZegoTextMessage.formJson(item);
      textPeerMessageReceivedList[fromUserID]?.add(message);
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
