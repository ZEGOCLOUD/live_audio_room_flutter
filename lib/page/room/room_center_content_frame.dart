import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:live_audio_room_flutter/common/style/styles.dart';
import 'package:live_audio_room_flutter/model/zego_room_user_role.dart';
import 'package:live_audio_room_flutter/model/zego_speaker_seat.dart';
import 'package:live_audio_room_flutter/model/zego_user_info.dart';
import 'package:live_audio_room_flutter/service/zego_room_service.dart';
import 'package:live_audio_room_flutter/service/zego_speaker_seat_service.dart';
import 'package:live_audio_room_flutter/service/zego_user_service.dart';
import 'package:provider/provider.dart';

typedef SeatItemClickCallback = Function(int index, String userId);

class SeatItem extends StatelessWidget {
  final int index;
  final String userID;
  final String? userName;
  final bool? mic;
  final ZegoSpeakerSeatStatus? status;
  final double? soundLevel;
  final double? network;
  final String? avatar;
  final SeatItemClickCallback callback;

  const SeatItem(
      {required this.index,
      required this.userID,
      this.userName,
      this.mic,
      this.status,
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
                        backgroundColor: Color(0xFFE6E6E6),
                        backgroundImage:
                            AssetImage(StyleIconUrls.roomSeatDefault),
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
                print("Button click...");
                callback(index, userID);
              },
              child: const Text(""),
            ),
          )
        ],
      ),
    );
  }
}

class RoomCenterContentFrame extends StatelessWidget {
  const RoomCenterContentFrame({Key? key}) : super(key: key);

  _createSeats(List<ZegoSpeakerSeat> seatList, List<ZegoUserInfo> userInfoList,
      SeatItemClickCallback callback) {
    var userIDNameMap = <String, String>{};
    for (var userInfo in userInfoList) {
      userIDNameMap[userInfo.userId] = userInfo.userName;
    }
    var itemList = <SeatItem>[];
    for (var i = 0; i < 8; i++) {
      var seat = seatList[i];
      var item = SeatItem(
        index: i,
        userID: seat.userID,
        userName: userIDNameMap[seat.userID],
        mic: seat.mic,
        soundLevel: seat.soundLevel,
        avatar: "images/seat_$i.png",
        callback: callback,
      );
      itemList.add(item);
    }
    return itemList;
  }

  @override
  Widget build(BuildContext context) {
    seatClickCallback(ZegoRoomUserRole userRole) {
      if (ZegoRoomUserRole.roomUserRoleHost == userRole) {
        return (int index, String userID) {
          // Process host click
        };
      } else if (ZegoRoomUserRole.roomUserRoleSpeaker == userRole) {
        return (int index, String userID) {
          // Process speaker click
          var users = context.read<ZegoUserService>();
          if (users.localUserInfo.userId == userID) {
            return;
          }
          var seats = context.read<ZegoSpeakerSeatService>();
          seats.switchSeat(index, (p0) => null);
        };
      } else {
        return (int index, String userID) {
          // Process listener click
          print("Listener($userID) click the item with index($index).");
          var users = context.read<ZegoUserService>();
          if (users.localUserInfo.userId == userID) {
            return;
          }
          var seats = context.read<ZegoSpeakerSeatService>();
          seats.takeSeat(index, (p0) => null);
          // users.localUserInfo.userRole = ZegoRoomUserRole.roomUserRoleSpeaker;
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
            height: 212.h * 2,
            width: 622.w, //(152.w + 22.w) * 3,

            child: Consumer2<ZegoSpeakerSeatService, ZegoUserService>(
              builder: (context, seats, users, child) => GridView.count(
                childAspectRatio: (152 / 165),
                primary: false,
                crossAxisSpacing: 22.w,
                mainAxisSpacing: 0,
                crossAxisCount: 4,
                children: _createSeats(seats.speakerSeatList, users.userList,
                    seatClickCallback(users.localUserInfo.userRole)),
              ),
            ),
          ),
          const Expanded(child: Text("Message"))
        ],
      ),
    );
  }
}
