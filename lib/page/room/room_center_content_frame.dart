import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../service/zego_gift_service.dart';
import '../../service/zego_user_service.dart';
import '../../service/zego_speaker_seat_service.dart';

import 'package:flutter_gen/gen_l10n/live_audio_room_localizations.dart';
import '../../model/zego_user_info.dart';
import '../../common/user_avatar.dart';

import '../../page/room/message/room_message_page.dart';
import '../../common/room_info_content.dart';
import '../../model/zego_room_user_role.dart';
import '../../model/zego_speaker_seat.dart';
import '../../page/room/gift/room_gift_tips.dart';
import '../../page/room/room_seat_item.dart';
import '../../constants/zego_room_constant.dart';

class RoomCenterContentFrame extends StatefulWidget {
  const RoomCenterContentFrame({Key? key}) : super(key: key);

  @override
  _RoomCenterContentFrameState createState() => _RoomCenterContentFrameState();
}

class _RoomCenterContentFrameState extends State<RoomCenterContentFrame> {
  ValueNotifier<bool> hasDialog = ValueNotifier<bool>(false);

  _createSeats(List<ZegoSpeakerSeat> seatList, List<ZegoUserInfo> userInfoList,
      SeatItemClickCallback callback) {
    var userService = context.read<ZegoUserService>();
    var itemList = <SeatItem>[];
    for (var i = 0; i < 8; i++) {
      var seat = seatList[i];
      var userInfo = userService.getUserByID(seat.userID);
      var avatarIndex = getUserAvatarIndex(userInfo.userName);
      var item = SeatItem(
        index: i,
        userID: seat.userID,
        userName: userInfo.userName,
        mic: seat.mic,
        status: seat.status,
        soundLevel: seat.soundLevel,
        networkQuality: seat.network,
        avatar: "images/seat_$avatarIndex.png",
        callback: callback,
      );
      itemList.add(item);
    }
    return itemList;
  }

  _showBottomModalButton(
      BuildContext context, String buttonText, VoidCallback callback) {
    hasDialog.value = true;

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
                children: [
                  SizedBox(
                    height: 98.h,
                    width: 630.w,
                    child: CupertinoButton(
                        color: Colors.white,
                        onPressed: () {
                          Navigator.pop(context);
                          callback();
                        },
                        child: Text(
                          buttonText,
                          style: TextStyle(
                              color: const Color(0xFF1B1B1B), fontSize: 28.sp),
                        )),
                  ),
                ],
              ));
        }).then((value) {
      hasDialog.value = false;
    });
  }

  _showDialog(BuildContext context, String title, String description,
      {String? cancelButtonText,
      String? confirmButtonText,
      VoidCallback? callback}) {
    hasDialog.value = true;

    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              hasDialog.value = false;
              Navigator.pop(
                  context,
                  cancelButtonText ??
                      AppLocalizations.of(context)!.dialogCancel);
            },
            child: Text(confirmButtonText ??
                AppLocalizations.of(context)!.dialogCancel),
          ),
          TextButton(
            onPressed: () {
              hasDialog.value = false;

              Navigator.pop(
                  context, AppLocalizations.of(context)!.dialogConfirm);

              if (callback != null) {
                callback();
              }
            },
            child: Text(AppLocalizations.of(context)!.dialogConfirm),
          ),
        ],
      ),
    );
  }

  _hostItemClickCallback(
      int index, String userID, String userName, ZegoSpeakerSeatStatus status) {
    if (index == 0) {
      return;
    }
    if (userID.isEmpty) {
      // Close or Unclose Seat
      var setToClose = ZegoSpeakerSeatStatus.closed != status;
      var buttonText = setToClose
          ? AppLocalizations.of(context)!.roomPageLockSeat
          : AppLocalizations.of(context)!.roomPageUnlockSeat;
      _showBottomModalButton(context, buttonText, () {
        var seats = context.read<ZegoSpeakerSeatService>();
        seats.closeSeat(setToClose, index).then((code) {
          if (code != 0) {
            Fluttertoast.showToast(
                msg: AppLocalizations.of(context)!.toastLockSeatAlreadyTakeSeat,
                backgroundColor: Colors.grey);
          }
        });
      });
    } else {
      // Remove user from seat
      _showBottomModalButton(
          context, AppLocalizations.of(context)!.roomPageLeaveSpeakerSeat, () {
        var seats = context.read<ZegoSpeakerSeatService>();
        if (!seats.isSeatOccupied(index)) {
          return;
        }

        _showDialog(
            context,
            AppLocalizations.of(context)!.roomPageLeaveSpeakerSeat,
            AppLocalizations.of(context)!
                .roomPageLeaveSpeakerSeatDesc(userName), callback: () {
          var seats = context.read<ZegoSpeakerSeatService>();
          seats.removeUserFromSeat(index).then((code) {
            if (code != 0) {
              Fluttertoast.showToast(
                  msg: AppLocalizations.of(context)!
                      .toastKickoutLeaveSeatError(userName, code),
                  backgroundColor: Colors.grey);
            }
          });
        });
      });
    }
  }

  _speakerItemClickCallback(
      int index, String userID, String userName, ZegoSpeakerSeatStatus status) {
    var users = context.read<ZegoUserService>();
    var seats = context.read<ZegoSpeakerSeatService>();

    if (userID.isEmpty) {
      if (ZegoSpeakerSeatStatus.closed == status) {
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.thisSeatHasBeenClosed,
            backgroundColor: Colors.grey);
        return;
      }
      _showBottomModalButton(
          context, AppLocalizations.of(context)!.roomPageTakeSeat, () {
        if (ZegoSpeakerSeatStatus.closed == seats.seatList[index].status) {
          Fluttertoast.showToast(
              msg: AppLocalizations.of(context)!.thisSeatHasBeenClosed,
              backgroundColor: Colors.grey);
          return;
        }

        seats.switchSeat(index).then((errorCode) {
          if (0 != errorCode) {
            Fluttertoast.showToast(
                msg: AppLocalizations.of(context)!
                    .toastTakeSpeakerSeatFail(errorCode),
                backgroundColor: Colors.grey);
          }
        });
      });
    } else if (users.localUserInfo.userID == userID) {
      _showBottomModalButton(
          context, AppLocalizations.of(context)!.roomPageLeaveSpeakerSeat, () {
        var seats = context.read<ZegoSpeakerSeatService>();
        if (!seats.isLocalInSeat()) {
          Fluttertoast.showToast(
              msg: AppLocalizations.of(context)!.toastLeaveSeatFail(-1),
              backgroundColor: Colors.grey);
          return;
        }

        _showDialog(
            context,
            AppLocalizations.of(context)!.roomPageLeaveSpeakerSeat,
            AppLocalizations.of(context)!.dialogSureToLeaveSeat, callback: () {
          var seats = context.read<ZegoSpeakerSeatService>();
          seats.leaveSeat().then((code) {
            if (code != 0) {
              Fluttertoast.showToast(
                  msg: AppLocalizations.of(context)!.toastLeaveSeatFail(code),
                  backgroundColor: Colors.grey);
            }
          });
        });
      });
    } else {
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.thisSeatHasBeenClosed,
          backgroundColor: Colors.grey);
    }
  }

  _listenerItemClickCallback(
      int index, String userID, String userName, ZegoSpeakerSeatStatus status) {
    if (userID.isNotEmpty) {
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.thisSeatHasBeenClosed,
          backgroundColor: Colors.grey);
      return;
    }
    if (ZegoSpeakerSeatStatus.closed == status) {
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.thisSeatHasBeenClosed,
          backgroundColor: Colors.grey);
      return;
    }
    _showBottomModalButton(
        context, AppLocalizations.of(context)!.roomPageTakeSeat, () async {
      var seatService = context.read<ZegoSpeakerSeatService>();

      if (ZegoSpeakerSeatStatus.closed == seatService.seatList[index].status) {
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.thisSeatHasBeenClosed,
            backgroundColor: Colors.grey);
        return;
      }

      var status = await Permission.microphone.request();
      seatService.setMicrophoneDefaultMute(!status.isGranted);

      seatService.takeSeat(index).then((code) {
        if (code != 0) {
          Fluttertoast.showToast(
              msg: AppLocalizations.of(context)!.toastTakeSpeakerSeatFail(code),
              backgroundColor: Colors.grey);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    getSeatClickCallbackByUserRole(ZegoRoomUserRole userRole) {
      switch (userRole) {
        case ZegoRoomUserRole.roomUserRoleHost:
          return _hostItemClickCallback;
        case ZegoRoomUserRole.roomUserRoleSpeaker:
          return _speakerItemClickCallback;
        case ZegoRoomUserRole.roomUserRoleListener:
          return _listenerItemClickCallback;
      }
    }

    return Container(
      padding: EdgeInsets.fromLTRB(38.w, 46.h, 38.w, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            //height: 212.h * 2,
            height: 330.h,
            width: 622.w, //(152.w + 22.w) * 3,
            child: Consumer2<ZegoSpeakerSeatService, ZegoUserService>(
              builder: (context, seats, users, child) => GridView.count(
                childAspectRatio: (152 / 165),
                primary: false,
                crossAxisSpacing: 22.w,
                mainAxisSpacing: 0,
                crossAxisCount: 4,
                children: _createSeats(
                    seats.seatList,
                    users.userList,
                    getSeatClickCallbackByUserRole(
                        users.localUserInfo.userRole)),
              ),
            ),
          ),
          const Expanded(child: Text('')),
          Consumer<ZegoGiftService>(
              builder: (_, giftService, child) => Visibility(
                  visible: giftService.displayTips,
                  child: _getRoomGiftTips(context, giftService))),
          SizedBox(height: 18.h),
          ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 632.w,
                maxWidth: 632.w,
                minHeight: 1.h,
                maxHeight: 570.h, //  630.h change by gift tips
              ),
              child: ChatMessagePage()),
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
      ),
    );
  }

  Widget _getRoomGiftTips(BuildContext context, ZegoGiftService giftService) {
    var userService = context.read<ZegoUserService>();
    String senderName =
        userService.getUserByID(giftService.giftSender).userName;
    List<String> receiverNames = [];
    for (var userID in giftService.giftReceivers) {
      receiverNames.add(userService.getUserByID(userID).userName);
    }
    return RoomGiftTips(
      gift: GiftMessageModel(senderName, receiverNames, giftService.giftID),
    );
  }
}
