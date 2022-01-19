import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:live_audio_room_flutter/service/zego_message_service.dart';
import 'package:live_audio_room_flutter/service/zego_user_service.dart';
import 'package:live_audio_room_flutter/common/style/styles.dart';
import 'package:live_audio_room_flutter/model/zego_user_info.dart';
import 'package:live_audio_room_flutter/model/zego_room_user_role.dart';
import 'package:live_audio_room_flutter/page/room/room_gift_tips.dart';
import 'package:flutter_gen/gen_l10n/live_audio_room_localizations.dart';

class ChatMessageModel {
  ZegoUserInfo sender = ZegoUserInfo.empty();
  ZegoTextMessage message = ZegoTextMessage();

  ChatMessageModel(this.sender, this.message);
}

class ChatMessageItem extends StatelessWidget {
  const ChatMessageItem({Key? key, required this.messageModel})
      : super(key: key);
  final ChatMessageModel messageModel;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Flexible(
        flex: 10,
        child: Container(
          padding:
              EdgeInsets.only(left: 21.w, top: 21.h, right: 21.w, bottom: 21.h),
          margin: EdgeInsets.only(bottom: 20.h),
          decoration: BoxDecoration(
            color: StyleColors.roomChatBackgroundColor,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: RichText(
              textAlign: TextAlign.start,
              text: TextSpan(children: <TextSpan>[
                getRoleWidget(context, messageModel.sender),
                getSpacerWidgetByRole(messageModel.sender),
                TextSpan(
                    text: messageModel.sender.userName + ": ",
                    style: StyleConstant.roomChatUserNameText),
                TextSpan(
                    text: messageModel.message.message,
                    style: StyleConstant.roomChatMessageText),
              ])),
        ),
      ),
      const Expanded(flex: 1, child: Text('')),
    ]);
  }

  TextSpan getRoleWidget(context, ZegoUserInfo sender) {
    if (ZegoRoomUserRole.roomUserRoleHost == sender.userRole) {
      return TextSpan(
          text: AppLocalizations.of(context)!.roomPageHost,
          style: StyleConstant.roomChatHostRoleText);
    }
    return const TextSpan(text: '');
  }

  TextSpan getSpacerWidgetByRole(ZegoUserInfo sender) {
    if (ZegoRoomUserRole.roomUserRoleHost == sender.userRole) {
      return const TextSpan(text: " ");
    }
    return const TextSpan(text: '');
  }
}

class ChatMessagePage extends StatefulWidget {
  const ChatMessagePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ChatMessagePageState();
  }
}

class _ChatMessagePageState extends State<ChatMessagePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(right: (118 - 32).w),
        child: Consumer2<ZegoMessageService, ZegoUserService>(
            builder: (_, messageService, userService, child) =>
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: messageService.messageList.length,
                  itemBuilder: (_, index) {
                    var message = messageService.messageList[index];
                    ChatMessageModel messageModel = ChatMessageModel(
                        userService.userDic[message.userID] ??
                            ZegoUserInfo.empty(),
                        message);
                    return ChatMessageItem(messageModel: messageModel);
                  },
                )));
  }
}
