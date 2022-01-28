import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:live_audio_room_flutter/service/zego_speaker_seat_service.dart';
import 'package:provider/provider.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:live_audio_room_flutter/service/zego_room_service.dart';
import 'package:live_audio_room_flutter/common/style/styles.dart';
import 'package:flutter_gen/gen_l10n/live_audio_room_localizations.dart';

class RoomSettingPage extends HookWidget {
  const RoomSettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          const BoxDecoration(color: StyleColors.roomPopUpPageBackgroundColor),
      padding:
          EdgeInsets.only(left: 36.w, top: 20.h, right: 36.w, bottom: 20.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
              height: 72.h,
              width: double.infinity,
              child: Center(
                  child: Text(AppLocalizations.of(context)!.roomPageSettings,
                      style: StyleConstant.roomBottomPopUpTitle))),
          SizedBox(height: 20.h),
          SizedBox(
              height: 108.h,
              child: Row(
                children: [
                  Text(AppLocalizations.of(context)!.roomPageSetTakeSeat,
                      style: StyleConstant.roomSettingSwitchText),
                  const Expanded(child: Text('')),
                  Consumer<ZegoRoomService>(
                      builder: (_, roomService, child) => Switch(
                            activeColor: StyleColors.switchActiveColor,
                            activeTrackColor:
                                StyleColors.switchActiveTrackColor,
                            inactiveTrackColor:
                                StyleColors.switchInactiveTrackColor,
                            value: roomService.roomInfo.isSeatClosed,
                            onChanged: (value) {
                              var seatService =
                                  context.read<ZegoSpeakerSeatService>();
                              seatService
                                  .closeAllSeat(value, roomService.roomInfo)
                                  .then((errorCode) {
                                if (0 != errorCode) {
                                  Fluttertoast.showToast(
                                      msg: AppLocalizations.of(context)!
                                          .toastLockSeatError(errorCode),
                                      backgroundColor: Colors.grey);
                                }
                              });
                            },
                          ))
                ],
              )),
          SizedBox(
              height: 108.h,
              child: Row(
                children: [
                  Text(AppLocalizations.of(context)!.roomPageSetSilence),
                  const Expanded(child: Text('')),
                  Consumer<ZegoRoomService>(
                      builder: (_, roomService, child) => Switch(
                            activeColor: StyleColors.switchActiveColor,
                            activeTrackColor:
                                StyleColors.switchActiveTrackColor,
                            inactiveTrackColor:
                                StyleColors.switchInactiveTrackColor,
                            value: roomService.roomInfo.isTextMessageDisable,
                            onChanged: (value) {
                              roomService
                                  .disableTextMessage(value)
                                  .then((errorCode) {
                                String message = '';
                                if (0 != errorCode) {
                                  message = AppLocalizations.of(context)!
                                      .toastMuteMessageError(errorCode);
                                } else {
                                  if (value) {
                                    message = AppLocalizations.of(context)!
                                        .toastDisableTextChatSuccess;
                                  } else {
                                    message = AppLocalizations.of(context)!
                                        .toastAllowTextChatSuccess;
                                  }
                                }
                                Fluttertoast.showToast(
                                    msg: message, backgroundColor: Colors.grey);
                              });
                            },
                          ))
                ],
              )),
          const Expanded(child: Text(''))
        ],
      ),
    );
  }
}
