import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:live_audio_room_flutter/common/style/styles.dart';
import 'package:live_audio_room_flutter/page/room/room_setting_page.dart';
import 'package:live_audio_room_flutter/page/room/room_member_page.dart';
import 'package:live_audio_room_flutter/page/room/room_gift_page.dart';

class ControllerButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon;

  const ControllerButton(
      {Key? key, required this.onPressed, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: IconButton(onPressed: onPressed, icon: icon),
    );
  }
}

class RoomControlButtonsBar extends StatelessWidget {
  const RoomControlButtonsBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ControllerButton(
            icon: Image.asset(StyleIconUrls.roomBottomIm),
            onPressed: () {},
          ),
          Row(
            children: [
              ControllerButton(
                icon: Image.asset(StyleIconUrls.roomBottomMicrophone),
                onPressed: () {},
              ),
              ControllerButton(
                icon: Image.asset(StyleIconUrls.roomBottomMember),
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 800.h,
                      isDismissible: true,
                      builder: (BuildContext context) {
                        return RoomMemberPage();
                      });
                },
              ),
              ControllerButton(
                icon: Image.asset(StyleIconUrls.roomBottomGift),
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 800.h,
                      isDismissible: true,
                      builder: (BuildContext context) {
                        return RoomGiftPage();
                      });
                },
              ),
              ControllerButton(
                icon: Image.asset(StyleIconUrls.roomBottomSettings),
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 800.h,
                      isDismissible: true,
                      builder: (BuildContext context) {
                        return RoomSettingPage();
                      });
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
