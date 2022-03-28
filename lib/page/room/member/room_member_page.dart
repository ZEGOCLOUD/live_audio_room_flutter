import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/live_audio_room_localizations.dart';

import '../../../service/zego_user_service.dart';
import '../../../model/zego_user_info.dart';
import '../../../common/style/styles.dart';
import '../../../page/room/member/room_member_list_item.dart';

class RoomMemberPage extends HookWidget {
  const RoomMemberPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration:
          const BoxDecoration(color: StyleColors.roomPopUpPageBackgroundColor),
      padding: EdgeInsets.only(left: 0, top: 20.h, right: 0, bottom: 0),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
            height: 72.h,
            width: double.infinity,
            child: Consumer<ZegoUserService>(
                builder: (_, userService, child) => Center(
                    child: Text(
                        AppLocalizations.of(context)!
                            .roomPageUserList(userService.userList.length),
                        style: StyleConstant.roomBottomPopUpTitle)))),
        Consumer<ZegoUserService>(
            builder: (_, userService, child) => SizedBox(
                  width: double.infinity,
                  height: 658.h,
                  child: ListView.builder(
                    itemExtent: 108.h,
                    padding: EdgeInsets.only(
                        left: 36.w, top: 20.h, right: 46.w, bottom: 20.h),
                    itemCount: userService.userList.length,
                    itemBuilder: (_, i) {
                      ZegoUserInfo user = userService.userList[i];
                      return RoomMemberListItem(userInfo: user);
                    },
                  ),
                )),
      ]),
    ));
  }
}
