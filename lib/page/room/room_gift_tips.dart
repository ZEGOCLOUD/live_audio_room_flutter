import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:live_audio_room_flutter/service/zego_gift_service.dart';
import 'package:live_audio_room_flutter/service/zego_user_service.dart';

import 'package:live_audio_room_flutter/common/style/styles.dart';
import 'package:live_audio_room_flutter/model/zego_user_info.dart';
import 'package:live_audio_room_flutter/model/zego_room_user_role.dart';
import 'package:flutter_gen/gen_l10n/live_audio_room_localizations.dart';
import 'package:live_audio_room_flutter/model/zego_room_gift.dart';
import 'package:flutter_gen/gen_l10n/live_audio_room_localizations.dart';

class GiftMessageModel {
  String sender = '';
  List<String> receivers = [];
  String id = '';
  int count = 1;

  GiftMessageModel(this.sender, this.receivers, this.id);
}

class RoomGiftTips extends HookWidget {
  RoomGiftTips({Key? key, required this.gift}) : super(key: key);

  final GiftMessageModel gift;

  List<InlineSpan> getTextSpans(context) {
    var giftName = getGiftNameByID(context, int.parse(gift.id));

    String targetUserNames = '';
    for (var receiver in gift.receivers) {
      targetUserNames += receiver + ",";
    }
    targetUserNames = targetUserNames.substring(0, targetUserNames.length - 1);
    var tipsText = AppLocalizations.of(context)!
        .roomPageReceivedGiftTips(targetUserNames, giftName, gift.sender);
    List<InlineSpan> spans = [];
    tipsText.split(' ').forEach((text) {
      if (text == giftName) {
        spans.add(TextSpan(
            text: giftName + ' ', style: StyleConstant.giftMessageTypeText));
      } else {
        spans.add(TextSpan(text: text + ' '));
      }
    });

    return spans;
  }

  String getGiftNameByID(BuildContext context, int giftID) {
    var valueMap = {
      RoomGiftID.fingerHeart: AppLocalizations.of(context)!.roomPageGiftHeart,
    };

    return valueMap[RoomGiftID.values[giftID]] ?? '';
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
