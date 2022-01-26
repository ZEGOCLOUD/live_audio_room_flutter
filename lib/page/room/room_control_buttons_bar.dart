import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:zego_express_engine/zego_express_engine.dart';

import 'package:live_audio_room_flutter/service/zego_message_service.dart';
import 'package:live_audio_room_flutter/service/zego_room_service.dart';
import 'package:live_audio_room_flutter/service/zego_speaker_seat_service.dart';
import 'package:live_audio_room_flutter/service/zego_user_service.dart';

import 'package:live_audio_room_flutter/common/style/styles.dart';
import 'package:live_audio_room_flutter/model/zego_room_user_role.dart';
import 'package:live_audio_room_flutter/page/room/room_setting_page.dart';
import 'package:live_audio_room_flutter/page/room/room_member_page.dart';
import 'package:live_audio_room_flutter/page/room/room_gift_page.dart';
import 'package:live_audio_room_flutter/common/input/input_dialog.dart';
import 'package:flutter_gen/gen_l10n/live_audio_room_localizations.dart';

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

class RoomControlButtonsBar extends HookWidget {
  const RoomControlButtonsBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check microphone permission
    useEffect(() {
      _checkMicPermission(context).then((isEnable) {
        if (!isEnable) {
          // Mic flag always reset to enable after log int room. So toggle to disable it.
          var seatService = context.read<ZegoSpeakerSeatService>();
          seatService.toggleMic();
        }
      });
    }, const []);

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
                      _showMessageInput(context);
                    },
                  )),
          Consumer2<ZegoUserService, ZegoSpeakerSeatService>(
              builder: (_, users, seats, child) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: _createControllerButtons(
                        users.localUserInfo.userRole, seats.isMute,
                        micCallback: () {
                      _checkMicPermission(context).then((isEnable) {
                        if (isEnable) {
                          var seatService =
                              context.read<ZegoSpeakerSeatService>();
                          seatService.toggleMic();
                        }
                      });
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
                    }, moreCallback: () {
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
                                  children: _getMoreMenu(context),
                                ));
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

  _getMoreMenu(BuildContext context) {
    List<Widget> listItems = [];

    var inviteTakeSeat = SizedBox(
      height: 98.h,
      width: 630.w,
      child: CupertinoButton(
          color: Colors.white,
          child: Text(
            AppLocalizations.of(context)!.roomPageLeaveSeat,
            style: TextStyle(color: const Color(0xFF1B1B1B), fontSize: 28.sp),
          ),
          onPressed: () {
            Navigator.pop(context);
            _onLeaveSeatClicked(context);
          }),
    );
    listItems.add(inviteTakeSeat);

    return listItems;
  }

  _onLeaveSeatClicked(BuildContext context) {
    var seats = context.read<ZegoSpeakerSeatService>();
    _showDialog(context, AppLocalizations.of(context)!.roomPageLeaveSeat,
        AppLocalizations.of(context)!.dialogSureToLeaveSeat,
        confirmCallback: () {
      seats.leaveSeat().then((code) {
        if (code != 0) {
          Fluttertoast.showToast(
              msg: AppLocalizations.of(context)!.toastLeaveSeatFail(code),
              backgroundColor: Colors.grey);
        }
      });
    });
  }

  _showDialog(BuildContext context, String title, String description,
      {String? cancelButtonText,
      String? confirmButtonText,
      VoidCallback? confirmCallback}) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context,
                cancelButtonText ?? AppLocalizations.of(context)!.dialogCancel),
            child: Text(confirmButtonText ??
                AppLocalizations.of(context)!.dialogCancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(
                  context, AppLocalizations.of(context)!.dialogConfirm);

              if (confirmCallback != null) {
                confirmCallback();
              }
            },
            child: Text(AppLocalizations.of(context)!.dialogConfirm),
          ),
        ],
      ),
    );
  }

  _showMessageInput(BuildContext context) {
    InputDialog.show(context).then((value) {
      if (value?.isEmpty ?? true) {
        return;
      }

      var userService = context.read<ZegoUserService>();
      var roomService = context.read<ZegoRoomService>();

      if (ZegoRoomUserRole.roomUserRoleHost !=
              userService.localUserInfo.userRole &&
          roomService.roomInfo.isTextMessageDisable) {
        //  host disable message after listener pop up input dialog
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.roomPageBandsSendMessage,
            backgroundColor: Colors.grey);
        return;
      }

      var messageService = context.read<ZegoMessageService>();
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

  Future<bool> _checkMicPermission(BuildContext context) async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      _showDialog(context, AppLocalizations.of(context)!.roomPageMicCantOpen,
          AppLocalizations.of(context)!.roomPageGrantMicPermission,
          confirmCallback: () => openAppSettings());
      return false;
    } else {
      return true;
    }
  }

  _createControllerButtons(ZegoRoomUserRole userRole, bool isMute,
      {required VoidCallback micCallback,
      required VoidCallback memberCallback,
      required VoidCallback giftCallback,
      required VoidCallback moreCallback,
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
    var moreBtn = ControllerButton(
      iconSrc: StyleIconUrls.roomBottomMore,
      onPressed: moreCallback,
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
      buttons.add(moreBtn);
    } else {
      buttons.add(giftBtn);
    }

    return buttons;
  }
}
