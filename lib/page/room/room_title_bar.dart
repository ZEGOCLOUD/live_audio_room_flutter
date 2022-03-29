import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../service/zego_user_service.dart';
import '../../service/zego_room_service.dart';
import '../../service/zego_speaker_seat_service.dart';

import '../../common/room_info_content.dart';
import '../../model/zego_room_user_role.dart';
import '../../common/style/styles.dart';
import '../../constants/zego_page_constant.dart';
import 'package:flutter_gen/gen_l10n/live_audio_room_localizations.dart';

class RoomTitleBar extends HookWidget {
  RoomTitleBar({Key? key}) : super(key: key);

  ValueNotifier<bool> hasDialog = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(36.w, 0, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<ZegoRoomService>(
                builder: (context, roomService, child) => Text(
                  roomService.roomInfo.roomName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF1B1B1B),
                    fontWeight: FontWeight.bold,
                    fontSize: 32.sp,
                  ),
                ),
              ),
              Consumer<ZegoRoomService>(
                builder: (context, roomService, child) => Text(
                  "ID:" + roomService.roomInfo.roomID,
                  style: TextStyle(
                    color: const Color(0xFF606060),
                    fontSize: 20.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Expanded(child: Text('')),
        IconButton(
          icon: Image.asset(StyleIconUrls.roomTopQuit),
          iconSize: 68.w,
          onPressed: () {
            var userService = context.read<ZegoUserService>();
            var isLocalHost = ZegoRoomUserRole.roomUserRoleHost ==
                userService.localUserInfo.userRole;
            if (isLocalHost) {
              showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (context) => showEndRoomDialog(context),
              );
            } else {
              var seatService = context.read<ZegoSpeakerSeatService>();
              seatService.leaveSeat().then((value) {
                var roomService = context.read<ZegoRoomService>();
                roomService.leaveRoom().then((errorCode) {
                  if (0 != errorCode) {
                    Fluttertoast.showToast(
                        msg: AppLocalizations.of(context)!
                            .toastRoomLeaveFailTip(errorCode),
                        backgroundColor: Colors.grey);
                  } else {
                    Navigator.pushReplacementNamed(
                        context, PageRouteNames.roomEntrance);
                  }
                });
              });
            }
          },
        ),
        Consumer<ZegoUserService>(builder: (_, userService, child) {
          if (userService.notifyInfo.isEmpty) {
            return const Offstage(offstage: true, child: Text(''));
          }
          Future.delayed(Duration.zero, () async {
            var infoContent =
                RoomInfoContent.fromJson(jsonDecode(userService.notifyInfo));

            switch (infoContent.toastType) {
              case RoomInfoType.roomNetworkTempBroken:
                if (hasDialog.value) {
                  hasDialog.value = false;
                  Navigator.pop(context);
                }
                break;
              default:
                break;
            }
          });

          return const Offstage(offstage: true, child: Text(''));
        }),
      ],
    );
  }

  showEndRoomDialog(BuildContext context) {
    hasDialog.value = true;

    var title = Text(AppLocalizations.of(context)!.roomPageDestroyRoom);
    var content = Text(AppLocalizations.of(context)!.dialogSureToDestroyRoom);

    return AlertDialog(
      title: title,
      content: content,
      actions: <Widget>[
        TextButton(
          child: Text(AppLocalizations.of(context)!.dialogCancel),
          onPressed: () {
            hasDialog.value = false;

            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(AppLocalizations.of(context)!.dialogConfirm),
          onPressed: () {
            hasDialog.value = false;

            context.read<ZegoSpeakerSeatService>().leaveSeat().then((value) {
              var roomService = context.read<ZegoRoomService>();
              roomService.leaveRoom().then((errorCode) {
                if (0 != errorCode) {
                  Fluttertoast.showToast(
                      msg: AppLocalizations.of(context)!
                          .toastRoomEndFailTip(errorCode),
                      backgroundColor: Colors.grey);
                }
              });

              Navigator.of(context).pop(true);
              Navigator.pushReplacementNamed(
                  context, PageRouteNames.roomEntrance);
            });
          },
        ),
      ],
    );
  }
}
