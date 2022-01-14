import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:live_audio_room_flutter/common/style/styles.dart';
import 'package:live_audio_room_flutter/model/zego_user_info.dart';
import 'package:live_audio_room_flutter/model/zego_room_user_role.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GiftMessageModel {
  ZegoUserInfo fromUserInfo = ZegoUserInfo.empty();
  ZegoUserInfo toUserInfo = ZegoUserInfo.empty();
  String type = "";
  int count = 1;

  GiftMessageModel(this.fromUserInfo, this.toUserInfo, this.type);
}

class GiftMessageItem extends StatelessWidget {
  const GiftMessageItem({Key? key, required this.gift}) : super(key: key);
  final GiftMessageModel gift;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Flexible(
        flex: 10,
        child: Container(
          padding:
              EdgeInsets.only(left: 20.w, top: 24.h, right: 20.h, bottom: 24.h),
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
              text: TextSpan(children: <TextSpan>[
                TextSpan(
                    text: gift.fromUserInfo.userName,
                    style: StyleConstant.giftMessageContentText),
                TextSpan(
                    text: " has gifted " + gift.count.toString() + " ",
                    style: StyleConstant.giftMessageContentText),
                TextSpan(
                    text: gift.type + " ",
                    style: StyleConstant.giftMessageTypeText),
                TextSpan(
                    text: "to " + gift.toUserInfo.userName,
                    style: StyleConstant.giftMessageContentText),
              ])),
        ),
      ),
      const Expanded(flex: 1, child: Text('')),
    ]);
  }
}
