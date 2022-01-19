import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:live_audio_room_flutter/service/zego_room_service.dart';
import 'package:live_audio_room_flutter/service/zego_user_service.dart';

import 'package:live_audio_room_flutter/common/style/styles.dart';
import 'package:live_audio_room_flutter/page/room/room_chat_page.dart';
import 'package:live_audio_room_flutter/model/zego_room_user_role.dart';
import 'package:live_audio_room_flutter/model/zego_speaker_seat.dart';
import 'package:live_audio_room_flutter/model/zego_user_info.dart';
import 'package:live_audio_room_flutter/service/zego_speaker_seat_service.dart';
import 'package:live_audio_room_flutter/page/room/room_gift_tips.dart';
import 'package:flutter_gen/gen_l10n/live_audio_room_localizations.dart';

typedef SeatItemClickCallback = Function(
    int index, String userId, ZegoSpeakerSeatStatus status);

class SeatItem extends StatelessWidget {
  final int index;
  final String userID;
  final String? userName;
  final bool? mic;
  final ZegoSpeakerSeatStatus status;
  final double? soundLevel;
  final double? network;
  final String? avatar;
  final SeatItemClickCallback callback;

  const SeatItem(
      {required this.index,
      required this.userID,
      this.userName,
      this.mic,
      required this.status,
      this.soundLevel,
      this.network,
      this.avatar,
      required this.callback,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    (soundLevel ?? 0) > 0
                        ? Image.asset(StyleIconUrls.roomSoundWave)
                        : Container(
                            color: Colors.transparent,
                          ),
                    SizedBox(
                      width: 100.w,
                      height: 100.h,
                      child: CircleAvatar(
                        backgroundColor: const Color(0xFFE6E6E6),
                        backgroundImage: (ZegoSpeakerSeatStatus.Closed ==
                                status)
                            ? const AssetImage(StyleIconUrls.roomSeatLock)
                            : const AssetImage(StyleIconUrls.roomSeatDefault),
                        foregroundImage:
                            (avatar ?? "").isEmpty || (userName ?? "").isEmpty
                                ? null
                                : AssetImage(avatar!),
                      ),
                    ),
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
                Text(
                  userName ?? "",
                  style: TextStyle(fontSize: 20.sp),
                )
              ],
            ),
          ),
          Positioned.fill(
            child: TextButton(
              onPressed: () {
                callback(index, userID, status);
              },
              child: const Text(""),
            ),
          )
        ],
      ),
    );
  }
}

class RoomCenterContentFrame extends StatefulWidget {
  const RoomCenterContentFrame({Key? key}) : super(key: key);

  @override
  _RoomCenterContentFrameState createState() => _RoomCenterContentFrameState();
}

class _RoomCenterContentFrameState extends State<RoomCenterContentFrame> {
  bool giftTipsVisibility = false;

  //  todo@yyuj wait gift notify
  _showGiftTips() {
    setState(() {
      giftTipsVisibility = true;
    });
    Timer(const Duration(seconds: 10), () {
      setState(() {
        giftTipsVisibility = false;
      });
    });
  }

  _createSeats(List<ZegoSpeakerSeat> seatList, List<ZegoUserInfo> userInfoList,
      SeatItemClickCallback callback) {
    var userIDNameMap = <String, String>{};
    for (var userInfo in userInfoList) {
      userIDNameMap[userInfo.userID] = userInfo.userName;
    }
    var itemList = <SeatItem>[];
    for (var i = 0; i < 8; i++) {
      var seat = seatList[i];
      var item = SeatItem(
        index: i,
        userID: seat.userID,
        userName: userIDNameMap[seat.userID],
        mic: seat.mic,
        status: seat.status,
        soundLevel: seat.soundLevel,
        avatar: "images/seat_$i.png",
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

  @override
  Widget build(BuildContext context) {
    seatClickCallback(ZegoRoomUserRole userRole, {String? userName}) {
      if (ZegoRoomUserRole.roomUserRoleHost == userRole) {
        // Process host click
        return (int index, String userID, ZegoSpeakerSeatStatus status) {
          if (index == 0) {
            return;
          }
          if (userID.isEmpty) {
            // Close or Unclose Seat
            var setToClose = ZegoSpeakerSeatStatus.Closed != status;
            _showBottomModalButton(
                context,
                setToClose
                    ? AppLocalizations.of(context)!.roomPageLockSeat
                    : AppLocalizations.of(context)!.roomPageUnlockSeat, () {
              var seats = context.read<ZegoSpeakerSeatService>();
              seats.closeSeat(setToClose, index).then((code) {
                Fluttertoast.showToast(
                    msg:
                        AppLocalizations.of(context)!.toastLockSeatError(code));
              });
            });
          } else {
            // Remove user from seat
            _showBottomModalButton(
                context, AppLocalizations.of(context)!.roomPageLeaveSpeakerSeat,
                () {
              showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: Text(AppLocalizations.of(context)!.roomPageLeaveSeat),
                  content: Text(AppLocalizations.of(context)!
                      .roomPageLeaveSpeakerSeatDesc(userName!)),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(
                          context, AppLocalizations.of(context)!.dialogCancel),
                      child: Text(AppLocalizations.of(context)!.dialogCancel),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context,
                            AppLocalizations.of(context)!.dialogConfirm);

                        var seats = context.read<ZegoSpeakerSeatService>();
                        seats.removeUserFromSeat(index).then((code) {
                          Fluttertoast.showToast(
                              msg: AppLocalizations.of(context)!
                                  .toastKickoutLeaveSeatError(userName, code));
                        });
                      },
                      child: Text(AppLocalizations.of(context)!.dialogConfirm),
                    ),
                  ],
                ),
              );
            });
          }
        };
      } else if (ZegoRoomUserRole.roomUserRoleSpeaker == userRole) {
        // Process speaker click
        return (int index, String userID, ZegoSpeakerSeatStatus status) {
          print("Speaker click...$index, $userID");
          var users = context.read<ZegoUserService>();
          var seats = context.read<ZegoSpeakerSeatService>();

          if (userID.isEmpty) {
            _showBottomModalButton(
                context, AppLocalizations.of(context)!.roomPageTakeSeat, () {
              seats.switchSeat(index);
            });
          } else if (users.localUserInfo.userID == userID) {
            _showBottomModalButton(
                context, AppLocalizations.of(context)!.roomPageLeaveSeat, () {
              seats.leaveSeat().then((code) {
                if (code != 0) {
                  Fluttertoast.showToast(
                      msg: AppLocalizations.of(context)!
                          .toastLeaveSeatFail(code));
                }
              });
            });
          }
        };
      } else {
        // Process listener click
        return (int index, String userID, ZegoSpeakerSeatStatus status) {
          print("Listener click...$index, $userID");
          var users = context.read<ZegoUserService>();
          if (userID.isNotEmpty) {
            return;
          }
          if (ZegoSpeakerSeatStatus.Closed == status) {
            Fluttertoast.showToast(
                msg: AppLocalizations.of(context)!.thisSeatHasBeenClosed);
            return;
          }
          _showBottomModalButton(
              context, AppLocalizations.of(context)!.roomPageTakeSeat, () {
            var seats = context.read<ZegoSpeakerSeatService>();
            seats.takeSeat(index).then((code) {
              if (code != 0) {
                Fluttertoast.showToast(
                    msg: AppLocalizations.of(context)!
                        .toastTakeSpeakerSeatFail(code));
              }
            });
          });
        };
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
                children: _createSeats(seats.seatList, users.userList,
                    seatClickCallback(users.localUserInfo.userRole)),
              ),
            ),
          ),
          const Expanded(child: Text('')),
          //  todo@yuyj this is a test data
          Visibility(
              visible: giftTipsVisibility,
              child: RoomGiftTips(
                  gift: GiftMessageModel(
                      ZegoUserInfo(
                          "001", "Liam", ZegoRoomUserRole.roomUserRoleHost),
                      ZegoUserInfo(
                          "002", "Noah", ZegoRoomUserRole.roomUserRoleSpeaker),
                      "Rocket"))),
          SizedBox(height: 18.h),
          ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 632.w,
                maxWidth: 632.w,
                minHeight: 1.h,
                maxHeight: 630.h,
              ),
              child: const ChatMessagePage())
        ],
      ),
    );
  }
}
