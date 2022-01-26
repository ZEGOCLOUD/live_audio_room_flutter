import 'dart:async';
import 'dart:ffi';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:live_audio_room_flutter/service/zego_room_service.dart';
import 'package:live_audio_room_flutter/service/zego_gift_service.dart';
import 'package:live_audio_room_flutter/service/zego_user_service.dart';

import 'package:live_audio_room_flutter/common/style/styles.dart';
import 'package:live_audio_room_flutter/page/room/room_chat_page.dart';
import 'package:live_audio_room_flutter/model/zego_room_user_role.dart';
import 'package:live_audio_room_flutter/model/zego_speaker_seat.dart';
import 'package:live_audio_room_flutter/model/zego_user_info.dart';
import 'package:live_audio_room_flutter/service/zego_speaker_seat_service.dart';
import 'package:live_audio_room_flutter/page/room/room_gift_tips.dart';
import 'package:flutter_gen/gen_l10n/live_audio_room_localizations.dart';
import 'package:crypto/crypto.dart';

typedef SeatItemClickCallback = Function(
    int index, String userId, String? userName, ZegoSpeakerSeatStatus status);

class SeatItem extends StatelessWidget {
  final int index;
  final String userID;
  final String? userName;
  final bool? mic;
  final ZegoSpeakerSeatStatus status;
  final double? soundLevel;
  final ZegoNetworkQuality? networkQuality;
  final String? avatar;
  final SeatItemClickCallback callback;

  const SeatItem(
      {required this.index,
      required this.userID,
      this.userName,
      this.mic,
      required this.status,
      this.soundLevel,
      this.networkQuality,
      this.avatar,
      required this.callback,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String getNetworkQualityIconName() {
      switch ((networkQuality ?? ZegoNetworkQuality.Bad)) {
        case ZegoNetworkQuality.Good:
          return StyleIconUrls.roomNetworkStatusGood;
        case ZegoNetworkQuality.Medium:
          return StyleIconUrls.roomNetworkStatusNormal;
        case ZegoNetworkQuality.Bad:
        case ZegoNetworkQuality.Unknow:
          return StyleIconUrls.roomNetworkStatusBad;
      }
    }

    return SizedBox(
      height: 152.h + 30.h,
      width: 152.w,
      child: Stack(
        children: [
          // bottom layout
          Positioned.fill(
            child: Align(
                alignment: Alignment.topCenter,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // sound wave background
                    (soundLevel ?? 0) > 10
                        ? Image.asset(StyleIconUrls.roomSoundWave)
                        : Container(
                            color: Colors.transparent,
                          ),
                    // Avatar
                    SizedBox(
                      width: 100.w,
                      height: 100.h,
                      child: CircleAvatar(
                        backgroundColor: const Color(0xFFE6E6E6),
                        backgroundImage: _getSeatDefaultBackground(context),
                        foregroundImage:
                            (avatar ?? "").isEmpty || (userName ?? "").isEmpty
                                ? null
                                : AssetImage(avatar!),
                      ),
                    ),
                    // Microphone muted icon
                    (mic ?? false) || userID.isEmpty
                        ? Container(
                            color: Colors.transparent,
                          )
                        : Container(
                            width: 100.w,
                            height: 100.h,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                                StyleIconUrls.roomSeatMicrophoneMuted),
                          )
                  ],
                )),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                index == 0
                    ? Image.asset(StyleIconUrls.roomSeatsHost)
                    : Container(
                        color: Colors.transparent,
                      ),
                SizedBox(
                  height: 9.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      userName ?? "",
                      style: TextStyle(fontSize: 20.sp),
                    ),
                    userID.isEmpty
                        ? Container(
                            color: Colors.transparent,
                          )
                        : Image.asset(getNetworkQualityIconName())
                  ],
                )
              ],
            ),
          ),
          Positioned.fill(
            child: TextButton(
              onPressed: () {
                callback(index, userID, userName, status);
              },
              child: const Text(""),
            ),
          )
        ],
      ),
    );
  }

  _getSeatDefaultBackground(BuildContext context) {
    if (ZegoSpeakerSeatStatus.Closed == status) {
      return const AssetImage(StyleIconUrls.roomSeatLock);
    }

    var userService = context.read<ZegoUserService>();
    if (userService.localUserInfo.userRole ==
        ZegoRoomUserRole.roomUserRoleListener) {
      return const AssetImage(StyleIconUrls.roomSeatAdd);
    }
    return const AssetImage(StyleIconUrls.roomSeatDefault);
  }
}

class RoomCenterContentFrame extends StatefulWidget {
  const RoomCenterContentFrame({Key? key}) : super(key: key);

  @override
  _RoomCenterContentFrameState createState() => _RoomCenterContentFrameState();
}

class _RoomCenterContentFrameState extends State<RoomCenterContentFrame> {
  _createSeats(List<ZegoSpeakerSeat> seatList, List<ZegoUserInfo> userInfoList,
      SeatItemClickCallback callback) {
    var userIDNameMap = <String, String>{};
    for (var userInfo in userInfoList) {
      userIDNameMap[userInfo.userID] = userInfo.userName;
    }
    var itemList = <SeatItem>[];
    for (var i = 0; i < 8; i++) {
      var seat = seatList[i];
      var avatarCode = int.parse(
          md5
              .convert(utf8.encode((userIDNameMap[seat.userID] ?? "")))
              .toString()
              .substring(0, 2),
          radix: 16);
      var avatarIndex = avatarCode % 8;
      var item = SeatItem(
        index: i,
        userID: seat.userID,
        userName: userIDNameMap[seat.userID],
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
        });
  }

  _showDialog(BuildContext context, String title, String description,
      {String? cancelButtonText,
      String? confirmButtonText,
      VoidCallback? callback}) {
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

  _hostItemClickCallback(int index, String userID, String? userName,
      ZegoSpeakerSeatStatus status) {
    if (index == 0) {
      return;
    }
    if (userID.isEmpty) {
      // Close or Unclose Seat
      var setToClose = ZegoSpeakerSeatStatus.Closed != status;
      var buttonText = setToClose
          ? AppLocalizations.of(context)!.roomPageLockSeat
          : AppLocalizations.of(context)!.roomPageUnlockSeat;
      _showBottomModalButton(context, buttonText, () {
        var seats = context.read<ZegoSpeakerSeatService>();
        seats.closeSeat(setToClose, index).then((code) {
          if (code != 0) {
            Fluttertoast.showToast(
                msg: AppLocalizations.of(context)!.toastLockSeatError(code),
                backgroundColor: Colors.grey);
          }
        });
      });
    } else {
      // Remove user from seat
      _showBottomModalButton(
          context, AppLocalizations.of(context)!.roomPageLeaveSpeakerSeat, () {
        _showDialog(
            context,
            AppLocalizations.of(context)!.roomPageLeaveSeat,
            AppLocalizations.of(context)!
                .roomPageLeaveSpeakerSeatDesc(userName!), callback: () {
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

  _speakerItemClickCallback(int index, String userID, String? userName,
      ZegoSpeakerSeatStatus status) {
    print("Speaker click...$index, $userID");
    var users = context.read<ZegoUserService>();
    var seats = context.read<ZegoSpeakerSeatService>();

    if (userID.isEmpty) {
      if (ZegoSpeakerSeatStatus.Closed == status) {
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.thisSeatHasBeenClosed,
            backgroundColor: Colors.grey);
        return;
      }
      _showBottomModalButton(
          context, AppLocalizations.of(context)!.roomPageTakeSeat, () {
        seats.switchSeat(index);
      });
    } else if (users.localUserInfo.userID == userID) {
      _showBottomModalButton(
          context, AppLocalizations.of(context)!.roomPageLeaveSeat, () {
        _showDialog(context, AppLocalizations.of(context)!.roomPageLeaveSeat,
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

  _listenerItemClickCallback(int index, String userID, String? userName,
      ZegoSpeakerSeatStatus status) {
    print("Listener click...$index, $userID");
    var users = context.read<ZegoUserService>();
    if (userID.isNotEmpty) {
      return;
    }
    if (ZegoSpeakerSeatStatus.Closed == status) {
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.thisSeatHasBeenClosed,
          backgroundColor: Colors.grey);
      return;
    }
    _showBottomModalButton(
        context, AppLocalizations.of(context)!.roomPageTakeSeat, () {
      var seats = context.read<ZegoSpeakerSeatService>();
      seats.takeSeat(index).then((code) {
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
            height: 300.h,
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
                  child: RoomGiftTips(
                    gift: GiftMessageModel(giftService.giftSender,
                        giftService.giftReceivers, giftService.giftID),
                  ))),
          SizedBox(height: 18.h),
          ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 632.w,
                maxWidth: 632.w,
                minHeight: 1.h,
                maxHeight: 570.h, //  630.h change by gift tips
              ),
              child: const ChatMessagePage())
        ],
      ),
    );
  }
}
