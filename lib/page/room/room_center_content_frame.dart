import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:live_audio_room_flutter/common/style/styles.dart';

class SeatItem extends StatelessWidget {
  const SeatItem({Key? key}) : super(key: key);

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
                    Image.asset(StyleIconUrls.roomSoundWave),
                    SizedBox(
                      width: 100.w,
                      height: 100.h,
                      child: const CircleAvatar(
                        backgroundColor: Color(0xFFE6E6E6),
                        backgroundImage:
                            AssetImage(StyleIconUrls.roomSeatDefault),
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
                Image.asset(StyleIconUrls.roomSeatsHost),
                SizedBox(
                  height: 9.h,
                ),
                Text(
                  "User Name",
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
            child: GridView.count(
              childAspectRatio: (152 / 165),
              primary: false,
              crossAxisSpacing: 22.w,
              mainAxisSpacing: 0,
              crossAxisCount: 4,
              children: const <Widget>[
                SeatItem(),
                SeatItem(),
                SeatItem(),
                SeatItem(),
                SeatItem(),
                SeatItem(),
                SeatItem(),
                SeatItem(),
              ],
            ),
          ),
          const Expanded(child: Text("Message"))
        ],
      ),
    );
  }
}
