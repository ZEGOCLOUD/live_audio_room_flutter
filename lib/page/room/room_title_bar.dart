import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_audio_room_flutter/service/zego_room_service.dart';

import 'package:live_audio_room_flutter/common/style/styles.dart';
import 'package:flutter_gen/gen_l10n/live_audio_room_localizations.dart';

class RoomTitleBar extends StatelessWidget {
  const RoomTitleBar({Key? key}) : super(key: key);

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
                    fontSize: 32.sp,
                  ),
                ),
              ),
              Consumer<ZegoRoomService>(
                builder: (context, roomService, child) => Text(
                  roomService.roomInfo.roomID,
                  style: TextStyle(
                    color: const Color(0xFF606060),
                    fontSize: 20.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Image.asset(StyleIconUrls.roomTopQuit),
          iconSize: 68.w,
          onPressed: () {
            showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title:
                      Text(AppLocalizations.of(context)!.roomPageDestroyRoom),
                  content: Text(
                      AppLocalizations.of(context)!.dialogSureToDestroyRoom),
                  actions: <Widget>[
                    TextButton(
                      child: Text(AppLocalizations.of(context)!.dialogCancel),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: Text(AppLocalizations.of(context)!.dialogConfirm),
                      onPressed: () {
                        var room = context.read<ZegoRoomService>();
                        room.leaveRoom().then((errorCode) {
                          if (0 != errorCode) {
                            Fluttertoast.showToast(
                                msg: AppLocalizations.of(context)!
                                    .toastRoomLeaveFailTip(errorCode),
                                backgroundColor: Colors.grey);
                          }
                        });

                        Navigator.of(context).pop(true);
                        Navigator.pushReplacementNamed(
                            context, "/room_entrance");
                      },
                    ),
                  ],
                );
              },
            );
          },
        )
      ],
    );
  }
}
