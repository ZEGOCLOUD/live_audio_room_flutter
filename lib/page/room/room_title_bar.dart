import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:live_audio_room_flutter/common/style/styles.dart';
import 'package:live_audio_room_flutter/service/zego_room_service.dart';
import 'package:provider/provider.dart';

class RoomTitleBar extends StatelessWidget {
  const RoomTitleBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(36.w, 0, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<ZegoRoomService>(
                builder: (context, room, child) => Text(
                  room.roomInfo.roomName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF1B1B1B),
                    fontSize: 32.sp,
                  ),
                ),
              ),

              Consumer<ZegoRoomService>(
                builder: (context, room, child) => Text(
                  room.roomInfo.roomId,
                  style: TextStyle(
                    color: const Color(0xFF606060),
                    fontSize: 20.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Image.asset(StyleIconUrls.roomTopQuit),
          iconSize: 68.w,
          onPressed: () {},
        )
      ],
    );
  }
}
