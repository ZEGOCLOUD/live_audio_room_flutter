import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/live_audio_room_localizations.dart';

import '../../../common/style/styles.dart';
import '../../../model/zego_user_info.dart';
import '../../../model/zego_text_message.dart';
import '../../../model/zego_room_user_role.dart';

class ZegoMessageListItemModel {
  ZegoUserInfo sender = ZegoUserInfo.empty();
  ZegoTextMessage message = ZegoTextMessage();

  ZegoMessageListItemModel(this.sender, this.message);
}

class ZegoMessageListItem extends StatelessWidget {
  const ZegoMessageListItem({Key? key, required this.itemModel})
      : super(key: key);
  final ZegoMessageListItemModel itemModel;

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
    spans.add(getRoleWidget(context, itemModel.sender));
    spans.add(getSpacerWidgetByRole(itemModel.sender));
    if (itemModel.sender.userName.isNotEmpty) {
      spans.add(TextSpan(
          text: itemModel.sender.userName + ": ",
          style: StyleConstant.roomChatUserNameText));
    }

    var isMemberJoinedMessage = itemModel.message.message.contains(
        AppLocalizations.of(context)!
            .roomPageJoinedTheRoom
            .replaceAll('%@', '')
            .trim());
    var isMemberLeaveMessage = itemModel.message.message.contains(
        AppLocalizations.of(context)!
            .roomPageHasLeftTheRoom
            .replaceAll('%@', '')
            .trim());
    if (isMemberJoinedMessage || isMemberLeaveMessage) {
      spans.add(TextSpan(
          text: itemModel.message.message,
          style: StyleConstant.roomChatUserNameText));
    } else {
      spans.add(TextSpan(
          text: itemModel.message.message,
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
