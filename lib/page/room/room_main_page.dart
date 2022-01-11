import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:live_audio_room_flutter/page/room/room_center_content_frame.dart';
import 'package:live_audio_room_flutter/page/room/room_control_buttons_bar.dart';
import 'package:live_audio_room_flutter/page/room/room_title_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RoomMainPage extends StatelessWidget {
  const RoomMainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Center(
        child: Container(
          color: const Color(0xFFF4F4F6),
          // padding: const EdgeInsets.all(80.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children:  [
              SizedBox(
                height: 16.h,
              ),
              const RoomTitleBar(),
              const Expanded(child: RoomCenterContentFrame()),
              const RoomControlButtonsBar(),
            ],
          ),
        ),
      ),
    ));
  }
}
