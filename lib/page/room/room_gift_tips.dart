import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:live_audio_room_flutter/common/style/styles.dart';
import 'package:live_audio_room_flutter/model/zego_user_info.dart';
import 'package:live_audio_room_flutter/model/zego_room_user_role.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/live_audio_room_localizations.dart';

class GiftMessageModel {
  ZegoUserInfo fromUserInfo = ZegoUserInfo.empty();
  ZegoUserInfo toUserInfo = ZegoUserInfo.empty();
  String name = "";
  int count = 1;

  GiftMessageModel(this.fromUserInfo, this.toUserInfo, this.name);
}

class RoomGiftTips extends StatelessWidget {
  const RoomGiftTips({Key? key, required this.gift}) : super(key: key);
  final GiftMessageModel gift;

  List<InlineSpan> getTextSpans(context) {
    var tipsText = AppLocalizations.of(context)!.roomPageReceivedGiftTips(
        gift.toUserInfo.userName, gift.name, gift.fromUserInfo.userName);
    List<InlineSpan> spans = [];
    tipsText.split(' ').forEach((text) {
      if (text == gift.name) {
        spans.add(TextSpan(
            text: gift.name + ' ', style: StyleConstant.giftMessageTypeText));
      } else {
        spans.add(TextSpan(text: text + ' '));
      }
    });

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Flexible(
        flex: 10,
        child: Container(
          padding:
              EdgeInsets.only(left: 20.w, top: 23.h, right: 20.h, bottom: 24.h),
          margin: EdgeInsets.only(right: (118 - 32).w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                StyleColors.giftMessageBackgroundStartColor,
                StyleColors.giftMessageBackgroundEndColor,
              ],
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                  style: StyleConstant.giftMessageContentText,
                  children: getTextSpans(context))),
        ),
      ),
      const Expanded(flex: 1, child: Text('')),
    ]);
  }
}
