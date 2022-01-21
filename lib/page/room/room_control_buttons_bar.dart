import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:live_audio_room_flutter/common/style/styles.dart';
import 'package:live_audio_room_flutter/model/zego_room_user_role.dart';
import 'package:live_audio_room_flutter/page/room/room_setting_page.dart';
import 'package:live_audio_room_flutter/page/room/room_member_page.dart';
import 'package:live_audio_room_flutter/page/room/room_gift_page.dart';
import 'package:live_audio_room_flutter/service/zego_message_service.dart';
import 'package:live_audio_room_flutter/service/zego_room_service.dart';
import 'package:live_audio_room_flutter/service/zego_speaker_seat_service.dart';
import 'package:live_audio_room_flutter/service/zego_user_service.dart';
import 'package:provider/provider.dart';
import 'package:live_audio_room_flutter/common/input/input_dialog.dart';
import 'package:flutter_gen/gen_l10n/live_audio_room_localizations.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

class ControllerButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String iconSrc;

  ControllerButton({Key? key, required this.onPressed, required this.iconSrc})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 68.w,
        height: 68.w,
        decoration:
            const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Transform.scale(
          scale: 1.5,
          child: IconButton(
            onPressed: onPressed,
            icon: Image.asset(
              iconSrc,
            ),
          ),
        ));
  }
}

class RoomControlButtonsBar extends StatelessWidget {
  const RoomControlButtonsBar({Key? key}) : super(key: key);

  createControllerButtons(ZegoRoomUserRole userRole, bool isMute,
      {required VoidCallback micCallback,
      required VoidCallback memberCallback,
      required VoidCallback giftCallback,
      required VoidCallback settingsCallback}) {
    var buttons = <Widget>[];
    var micBtn = ControllerButton(
      iconSrc: isMute
          ? StyleIconUrls.roomBottomMicrophoneMuted
          : StyleIconUrls.roomBottomMicrophone,
      onPressed: micCallback,
    );
    var micBtnSpacing = SizedBox(
      width: 36.w,
    );
    var memberBtn = ControllerButton(
      iconSrc: StyleIconUrls.roomBottomMember,
      onPressed: memberCallback,
    );
    var memberBtnSpacing = SizedBox(
      width: 36.w,
    );
    var giftBtn = ControllerButton(
      iconSrc: StyleIconUrls.roomBottomGift,
      onPressed: giftCallback,
    );
    var giftBtnSpacing = SizedBox(
      width: 36.w,
    );
    var settingsBtn = ControllerButton(
      iconSrc: StyleIconUrls.roomBottomSettings,
      onPressed: settingsCallback,
    );
    if (ZegoRoomUserRole.roomUserRoleHost == userRole) {
      buttons.add(micBtn);
      buttons.add(micBtnSpacing);
      buttons.add(memberBtn);
      buttons.add(memberBtnSpacing);
      buttons.add(giftBtn);
      buttons.add(giftBtnSpacing);
      buttons.add(settingsBtn);
    } else if (ZegoRoomUserRole.roomUserRoleSpeaker == userRole) {
      buttons.add(micBtn);
      buttons.add(micBtnSpacing);
      buttons.add(giftBtn);
      buttons.add(giftBtnSpacing);
      buttons.add(settingsBtn);
    } else {
      buttons.add(giftBtn);
    }

    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(32.w, 22.h, 32.h, 22.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Consumer<ZegoRoomService>(
              builder: (_, roomService, child) => ControllerButton(
                    iconSrc: StyleIconUrls.roomBottomIm,
                    onPressed: () {
                      var userService = context.read<ZegoUserService>();
                      var localUser =
                          userService.userDic[roomService.localUserID];
                      if (ZegoRoomUserRole.roomUserRoleHost !=
                              localUser?.userRole &&
                          roomService.roomInfo.isTextMessageDisable) {
                        return;
                      }
                      showMessageInput(context);
                    },
                  )),
          Consumer2<ZegoUserService, ZegoSpeakerSeatService>(
              builder: (_, users, seats, child) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: createControllerButtons(
                        users.localUserInfo.userRole, seats.isMute,
                        micCallback: () {
                      var seatService = context.read<ZegoSpeakerSeatService>();
                      seatService.toggleMic();
                    }, memberCallback: () {
                      showModalBottomSheet(
                          context: context,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 800.h,
                          isDismissible: true,
                          builder: (BuildContext context) {
                            return RoomMemberPage();
                          });
                    }, giftCallback: () {
                      showModalBottomSheet(
                          context: context,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 800.h,
                          isDismissible: true,
                          builder: (BuildContext context) {
                            return RoomGiftPage();
                          });
                    }, settingsCallback: () {
                      showModalBottomSheet(
                          context: context,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 800.h,
                          isDismissible: true,
                          builder: (BuildContext context) {
                            return RoomSettingPage();
                          });
                    }),
                  ))
        ],
      ),
    );
  }

  showMessageInput(BuildContext context) {
    InputDialog.show(context).then((value) {
      if (value?.isEmpty ?? true) {
        return;
      }

      var messageService = context.read<ZegoMessageService>();
      var roomService = context.read<ZegoRoomService>();
      var userService = context.read<ZegoUserService>();
      messageService
          .sendTextMessage(roomService.roomInfo.roomID,
              userService.localUserInfo.userID, value!)
          .then((errorCode) {
        if (0 != errorCode) {
          Fluttertoast.showToast(
              msg: AppLocalizations.of(context)!
                  .toastSendMessageError(errorCode),
              backgroundColor: Colors.grey);
        }
      });
    });
  }
}
