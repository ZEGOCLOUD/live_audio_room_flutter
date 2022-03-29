import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/live_audio_room_localizations.dart';

import '../../../service/zego_speaker_seat_service.dart';
import '../../../service/zego_user_service.dart';
import '../../../service/zego_room_service.dart';
import '../../../common/style/styles.dart';
import '../../../model/zego_user_info.dart';
import '../../../model/zego_room_user_role.dart';

const userIDOfNoSpeakerUser = '-1000';
const userIDOfAllSpeaker = '-1001';

class RoomGiftMemberList extends HookWidget {
  const RoomGiftMemberList({required this.memberSelectNotify, Key? key})
      : super(key: key);

  final ValueChanged<ZegoUserInfo> memberSelectNotify;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400.h,
      width: 468.w,
      child: Container(
        decoration: BoxDecoration(
          color: StyleColors.giftMemberListBackgroundColor,
          borderRadius: BorderRadius.circular(17.0),
        ),
        child:
            Consumer<ZegoSpeakerSeatService>(builder: (_, seatService, child) {
          var roomService = context.read<ZegoRoomService>();
          var userService = context.read<ZegoUserService>();
          List<String> speakerIDList = [...seatService.speakerIDSet];
          if (ZegoRoomUserRole.roomUserRoleHost !=
              userService.localUserInfo.userRole) {
            speakerIDList.insert(0, roomService.roomInfo.hostID); //  add host
          }
          List<ZegoUserInfo> speakerList = [];
          for (var speakerID in speakerIDList) {
            if (!userService.userDic.containsKey(speakerID)) {
              continue;
            }
            speakerList
                .add(userService.userDic[speakerID] ?? ZegoUserInfo.empty());
          }
          if (speakerList.isEmpty) {
            //  display if empty
            speakerList.add(ZegoUserInfo(
                userIDOfNoSpeakerUser,
                AppLocalizations.of(context)!.roomPageGiftNoSpeaker,
                ZegoRoomUserRole.roomUserRoleListener));
          } else {
            //  notify all user on the list
            speakerList.insert(
                0,
                ZegoUserInfo(
                    userIDOfAllSpeaker,
                    AppLocalizations.of(context)!.roomPageSelectAllSpeakers,
                    ZegoRoomUserRole.roomUserRoleListener));
            //  remove self if you are on the list
            speakerList.removeWhere((userInfo) =>
                userService.localUserInfo.userID == userInfo.userID);
          }
          return ListView.builder(
            itemExtent: 84.h,
            padding: const EdgeInsets.only(left: 0),
            itemCount: speakerList.length,
            itemBuilder: (_, index) {
              ZegoUserInfo user = speakerList[index];
              return GestureDetector(
                  child: Container(
                      padding: EdgeInsets.only(left: 30.w),
                      child: Center(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 322.w,
                              child: Text(
                                user.userName,
                                textAlign: TextAlign.left,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                style: StyleConstant.roomGiftMemberListText,
                              ),
                            ),
                            const Expanded(child: Text(''))
                          ],
                        ),
                      )),
                  onTap: () {
                    if (userIDOfNoSpeakerUser == user.userID) {
                      return;
                    }
                    memberSelectNotify(user);
                  });
            },
          );
        }),
      ),
    );
  }
}
