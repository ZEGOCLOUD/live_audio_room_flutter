import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:live_audio_room_flutter/service/zego_user_service.dart';

import 'package:live_audio_room_flutter/common/style/styles.dart';
import 'package:live_audio_room_flutter/model/zego_room_user_role.dart';
import 'package:live_audio_room_flutter/constants/zego_room_constant.dart';

typedef SeatItemClickCallback = Function(
    int index, String userId, String userName, ZegoSpeakerSeatStatus status);

class SeatItem extends StatelessWidget {
  final int index;
  final String userID;
  final String userName;
  final bool? mic;
  final ZegoSpeakerSeatStatus status;
  final double? soundLevel;
  final ZegoNetworkQuality? networkQuality;
  final String avatar;
  final SeatItemClickCallback callback;

  const SeatItem(
      {required this.index,
      required this.userID,
      required this.userName,
      this.mic,
      required this.status,
      this.soundLevel,
      this.networkQuality,
      required this.avatar,
      required this.callback,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String getNetworkQualityIconName() {
      switch ((networkQuality ?? ZegoNetworkQuality.badQuality)) {
        case ZegoNetworkQuality.goodQuality:
          return StyleIconUrls.roomNetworkStatusGood;
        case ZegoNetworkQuality.mediumQuality:
          return StyleIconUrls.roomNetworkStatusNormal;
        case ZegoNetworkQuality.badQuality:
        case ZegoNetworkQuality.unknownQuality:
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
                      child: _getCircleAvatar(context),
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
                    SizedBox(
                      width: 108.w,
                      child: Text(
                        userName,
                        textAlign: TextAlign.center,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 20.sp),
                      ),
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

  _getCircleAvatar(BuildContext context) {
    var userService = context.read<ZegoUserService>();
    var isLocalUserOnSeat = userService.localUserInfo.userRole !=
        ZegoRoomUserRole.roomUserRoleListener;

    late AssetImage image;
    switch (status) {
      case ZegoSpeakerSeatStatus.unTaken:
        image = isLocalUserOnSeat
            ? const AssetImage(StyleIconUrls.roomSeatDefault)
            : const AssetImage(StyleIconUrls.roomSeatAdd);
        break;
      case ZegoSpeakerSeatStatus.occupied:
        image = AssetImage(avatar);
        break;
      case ZegoSpeakerSeatStatus.closed:
        image = const AssetImage(StyleIconUrls.roomSeatLock);
        break;
    }

    return CircleAvatar(
      backgroundColor: const Color(0xFFE6E6E6),
      foregroundImage: image,
    );
  }
}
