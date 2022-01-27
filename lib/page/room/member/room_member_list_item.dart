import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:live_audio_room_flutter/service/zego_room_service.dart';
import 'package:live_audio_room_flutter/service/zego_speaker_seat_service.dart';
import 'package:provider/provider.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:live_audio_room_flutter/service/zego_user_service.dart';

import 'package:live_audio_room_flutter/model/zego_room_user_role.dart';
import 'package:live_audio_room_flutter/model/zego_user_info.dart';
import 'package:live_audio_room_flutter/common/style/styles.dart';
import 'package:live_audio_room_flutter/common/user_avatar.dart';
import 'package:flutter_gen/gen_l10n/live_audio_room_localizations.dart';

class RoomMemberListItem extends StatelessWidget {
  const RoomMemberListItem({Key? key, required this.userInfo})
      : super(key: key);
  final ZegoUserInfo userInfo;

  @override
  Widget build(BuildContext context) {
    var avatarIndex = getUserAvatarIndex(userInfo.userName);
    return Row(
      children: [
        SizedBox(
          width: 68.w,
          height: 68.h,
          child: CircleAvatar(
            foregroundImage: AssetImage("images/seat_$avatarIndex.png"),
          ),
        ),
        const SizedBox(width: 24),
        Text(userInfo.userName, style: StyleConstant.roomMemberListNameText),
        const Expanded(child: Text('')),
        getRightWidgetByUserRole(context)
      ],
    );
  }

  Widget getRightWidgetByUserRole(BuildContext context) {
    switch (userInfo.userRole) {
      case ZegoRoomUserRole.roomUserRoleHost:
        return Text(AppLocalizations.of(context)!.roomPageRoleOwner,
            textDirection: TextDirection.rtl,
            style: StyleConstant.roomMemberListRoleText);
      case ZegoRoomUserRole.roomUserRoleSpeaker:
        return Text(AppLocalizations.of(context)!.roomPageRoleSpeaker,
            textDirection: TextDirection.rtl,
            style: StyleConstant.roomMemberListRoleText);
      case ZegoRoomUserRole.roomUserRoleListener:
        return _getListenerMenu(context);
    }
  }

  Widget _getListenerMenu(BuildContext context) {
    return SizedBox(
        width: 60.w,
        height: 60.h,
        child: IconButton(
          icon: Image.asset(StyleIconUrls.roomMemberMore),
          onPressed: () {
            showModalBottomSheet(
                context: context,
                isDismissible: true,
                backgroundColor: Colors.transparent,
                builder: (BuildContext context) {
                  return SizedBox(
                      height: 60.h + 98.h,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: _getMenuList(context),
                      ));
                });
          },
        ));
  }

  _getMenuList(BuildContext context) {
    List<Widget> listItems = [];

    var inviteTakeSeat = SizedBox(
      height: 98.h,
      width: 630.w,
      child: CupertinoButton(
          color: Colors.white,
          child: Text(
            AppLocalizations.of(context)!.roomPageInviteTakeSeat,
            style: TextStyle(color: const Color(0xFF1B1B1B), fontSize: 28.sp),
          ),
          onPressed: () {
            Navigator.pop(context);
            _onInviteTakeSeatClicked(context);
          }),
    );
    listItems.add(inviteTakeSeat);

    return listItems;
  }

  _onInviteTakeSeatClicked(BuildContext context) {
    var roomService = context.read<ZegoRoomService>();
    var seatService = context.read<ZegoSpeakerSeatService>();
    // Speaker ID Set not include host id
    if (seatService.speakerIDSet.length >= 7 ||
        roomService.roomInfo.isSeatClosed) {
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.roomPageNoMoreSeatAvailable,
          backgroundColor: Colors.grey);
      return;
    }

    // Call SDK to send invitation
    var userService = context.read<ZegoUserService>();
    userService.sendInvitation(userInfo.userID);
  }
}