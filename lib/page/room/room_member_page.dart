import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_audio_room_flutter/model/zego_room_user_role.dart';
import 'package:live_audio_room_flutter/model/zego_user_info.dart';
import 'package:live_audio_room_flutter/common/style/styles.dart';
import 'package:flutter_gen/gen_l10n/live_audio_room_localizations.dart';

//  menu action type of member list
enum RoomMemberListMenuAction {
  inviteToBeASpeaker, //  Invite to be a speaker
}

class RoomMemberListItem extends StatelessWidget {
  const RoomMemberListItem({Key? key, required this.userInfo})
      : super(key: key);
  final ZegoUserInfo userInfo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 68.w,
          height: 68.h,
          child: CircleAvatar(
            child: Text(userInfo.userId),
          ),
        ),
        const SizedBox(width: 24),
        Text(userInfo.userName, style: StyleConstant.roomMemberListNameText),
        const Expanded(child: Text('')),
        getRightWidgetByUserRole(context)
      ],
    );
  }

  void onMoreMenuSelected(RoomMemberListMenuAction action) {
    //  todo@yuyj call service api
    switch (action) {
      case RoomMemberListMenuAction.inviteToBeASpeaker:
        break;
    }
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
        return SizedBox(
            width: 60.w,
            height: 60.h,
            child: PopupMenuButton(
                icon: Image.asset(StyleIconUrls.roomMemberMore),
                elevation: 5,
                offset: Offset(0, 0.h),
                padding: const EdgeInsets.all(5),
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                color: Colors.white,
                onSelected: (value) => onMoreMenuSelected,
                itemBuilder: (context) {
                  return <PopupMenuEntry<RoomMemberListMenuAction>>[
                    PopupMenuItem<RoomMemberListMenuAction>(
                      height: 98.h,
                      value: RoomMemberListMenuAction.inviteToBeASpeaker,
                      child: SizedBox(
                          width: 630.0.w,
                          child: Text(
                              AppLocalizations.of(context)!
                                  .roomPageInviteTakeSeat,
                              textAlign: TextAlign.center)),
                    ),
                  ];
                }));
    }
  }
}

class RoomMemberPage extends StatefulWidget {
  const RoomMemberPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RoomMemberPageState();
  }
}

class _RoomMemberPageState extends State<RoomMemberPage> {
  //  todo@yuyuj this is some test data
  final List<ZegoUserInfo> _users = [
    ZegoUserInfo('0001', 'Liam', ZegoRoomUserRole.roomUserRoleHost),
    ZegoUserInfo('0002', 'Noah', ZegoRoomUserRole.roomUserRoleSpeaker),
    ZegoUserInfo('0003', 'Oliver', ZegoRoomUserRole.roomUserRoleSpeaker),
    ZegoUserInfo('0004', 'William', ZegoRoomUserRole.roomUserRoleListener),
    ZegoUserInfo('0005', 'Elijah', ZegoRoomUserRole.roomUserRoleListener),
    ZegoUserInfo('0006', 'James', ZegoRoomUserRole.roomUserRoleListener),
    ZegoUserInfo('0007', 'Benjamin', ZegoRoomUserRole.roomUserRoleListener),
    ZegoUserInfo('0008', 'Lucas', ZegoRoomUserRole.roomUserRoleListener),
    ZegoUserInfo('0009', 'Mason', ZegoRoomUserRole.roomUserRoleListener),
    ZegoUserInfo('0010', 'Ethan', ZegoRoomUserRole.roomUserRoleListener),
    ZegoUserInfo('0011', 'Alexander', ZegoRoomUserRole.roomUserRoleListener)
  ];

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
            child: Center(
                child: Text(
                    AppLocalizations.of(context)!
                        .roomPageUserList(_users.length),
                    style: StyleConstant.roomBottomPopUpTitle))),
        SizedBox(
          width: double.infinity,
          height: 658.h,
          child: ListView.builder(
            itemExtent: 108.h,
            padding: EdgeInsets.only(
                left: 36.w, top: 20.h, right: 46.w, bottom: 20.h),
            itemCount: _users.length,
            itemBuilder: (_, i) {
              ZegoUserInfo user = _users[i];
              return RoomMemberListItem(userInfo: user);
            },
          ),
        ),
      ]),
    ));
  }
}
