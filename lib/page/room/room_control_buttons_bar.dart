import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
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
            icon: const Icon(Icons.chat),
            onPressed: () {},
          ),
          Row(
            children: [
              ControllerButton(
                icon: const Icon(Icons.mic),
                onPressed: () {},
              ),
              ControllerButton(
                icon: const Icon(Icons.people_alt),
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 400.h,
                      isDismissible: true,
                      builder: (BuildContext context) {
                        return RoomMemberPage();
                      });
                },
              ),
              ControllerButton(
                icon: const Icon(Icons.card_giftcard_outlined),
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 400.h,
                      isDismissible: true,
                      builder: (BuildContext context) {
                        return RoomGiftPage();
                      });
                },
              ),
              ControllerButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 400.h,
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
