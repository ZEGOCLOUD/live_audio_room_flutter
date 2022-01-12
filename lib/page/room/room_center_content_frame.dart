import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:live_audio_room_flutter/common/style/styles.dart';
import 'package:live_audio_room_flutter/model/zego_speaker_seat.dart';
import 'package:live_audio_room_flutter/service/zego_room_service.dart';
import 'package:live_audio_room_flutter/service/zego_speaker_seat_service.dart';
import 'package:provider/provider.dart';

class SeatItem extends StatelessWidget {
  final bool? isHost;
  final String? userName;
  final bool? mic;
  final ZegoSpeakerSeatStatus? status;
  final double? soundLevel;
  final double? network;
  final String? avatar;

  const SeatItem(
      {this.isHost,
      this.userName,
      this.mic,
      this.status,
      this.soundLevel,
      this.network,
      this.avatar,
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
                    )
                  ],
                )),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                (isHost ?? false)
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
          )
        ],
      ),
    );
  }
}

class RoomCenterContentFrame extends StatelessWidget {
  const RoomCenterContentFrame({Key? key}) : super(key: key);

  createSeats(List<ZegoSpeakerSeat> seatList) {
    for (var i = seatList.length - 1; i < 8; i++) {
      seatList.add(ZegoSpeakerSeat());
    }

    var itemList = <SeatItem>[];
    for (var i = 0; i < 8; i++) {
      var seat = seatList[i];
      var item = SeatItem(
        isHost: i == 0,
        userName: seat.userName,
        mic: seat.mic,
        soundLevel: seat.soundLevel,
        avatar: "images/seat_$i.png",
      );
      itemList.add(item);
    }
    return itemList;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(38.w, 46.h, 38.w, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 212.h * 2,
            width: 622.w, //(152.w + 22.w) * 3,

            child: Consumer<ZegoSpeakerSeatService>(
              builder: (context, seats, child) => GridView.count(
                childAspectRatio: (152 / 165),
                primary: false,
                crossAxisSpacing: 22.w,
                mainAxisSpacing: 0,
                crossAxisCount: 4,
                children: createSeats(seats.speakerSeatList),
              ),
            ),
          ),
          const Expanded(child: Text("Message"))
        ],
      ),
    );
  }
}
