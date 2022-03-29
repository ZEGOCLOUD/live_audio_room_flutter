import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/live_audio_room_localizations.dart';

import '../../../service/zego_message_service.dart';
import '../../../service/zego_user_service.dart';
import '../../../page/room/message/room_message_list_item.dart';

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
            ZegoMessageListItemModel messageModel = ZegoMessageListItemModel(
                userService.getUserByID(message.userID), message);
            return ZegoMessageListItem(itemModel: messageModel);
          },
        );
      }),
    );
  }
}
