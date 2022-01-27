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
              text: TextSpan(children: getMessageWidgets(context))),
        ),
      ),
      const Expanded(flex: 1, child: Text('')),
    ]);
  }

  List<TextSpan> getMessageWidgets(BuildContext context) {
    List<TextSpan> spans = [];
    spans.add(getRoleWidget(context, messageModel.sender));
    spans.add(getSpacerWidgetByRole(messageModel.sender));
    if (messageModel.sender.userName.isNotEmpty) {
      spans.add(TextSpan(
          text: messageModel.sender.userName + ": ",
          style: StyleConstant.roomChatUserNameText));
    }

    var isMemberJoinedMessage = messageModel.message.message.contains(
        AppLocalizations.of(context)!
            .roomPageJoinedTheRoom
            .replaceAll('%@', '')
            .trim());
    var isMemberLeaveMessage = messageModel.message.message.contains(
        AppLocalizations.of(context)!
            .roomPageHasLeftTheRoom
            .replaceAll('%@', '')
            .trim());
    if (isMemberJoinedMessage || isMemberLeaveMessage) {
      spans.add(TextSpan(
          text: messageModel.message.message,
          style: StyleConstant.roomChatUserNameText));
    } else {
      spans.add(TextSpan(
          text: messageModel.message.message,
          style: StyleConstant.roomChatMessageText));
    }

    return spans;
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

class ChatMessagePage extends HookWidget {
  ChatMessagePage({Key? key}) : super(key: key);
  final ScrollController _listviewCtrl = ScrollController();

  @override
  Widget build(BuildContext context) {
    var messageService = context.read<ZegoMessageService>();
    messageService.setTranslateTexts(
        AppLocalizations.of(context)!.roomPageJoinedTheRoom,
        AppLocalizations.of(context)!.roomPageHasLeftTheRoom);

    return Container(
      margin: EdgeInsets.only(right: (118 - 32).w),
      child: Consumer<ZegoMessageService>(builder: (_, messageService, child) {
        Timer(const Duration(milliseconds: 500),
            () => _listviewCtrl.jumpTo(_listviewCtrl.position.maxScrollExtent));

        var userService = context.read<ZegoUserService>();
        return ListView.builder(
          shrinkWrap: true,
          controller: _listviewCtrl,
          itemCount: messageService.messageList.length,
          itemBuilder: (_, index) {
            var message = messageService.messageList[index];
            ChatMessageModel messageModel = ChatMessageModel(
                userService.getUserByID(message.userID), message);
            return ChatMessageItem(messageModel: messageModel);
          },
        );
      }),
    );
  }
}
