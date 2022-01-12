import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:live_audio_room_flutter/common/style/styles.dart';
import 'package:live_audio_room_flutter/page/room/room_setting_page.dart';
import 'package:live_audio_room_flutter/page/room/room_member_page.dart';
import 'package:live_audio_room_flutter/page/room/room_gift_page.dart';

class ControllerButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String iconSrc;

  ControllerButton({Key? key, required this.onPressed, required this.iconSrc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 68.w,
        height: 68.w,
        decoration:
            const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Transform.scale(
          scale: 1.5,
          child: IconButton(
            onPressed: onPressed,
            icon: Image.asset(
              iconSrc,
            ),
          ),
        ));
  }
}

class RoomControlButtonsBar extends StatelessWidget {
  const RoomControlButtonsBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(32.w, 22.h, 32.h, 22.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ControllerButton(
            iconSrc: StyleIconUrls.roomBottomIm,
            onPressed: () {},
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ControllerButton(
                iconSrc: StyleIconUrls.roomBottomMicrophone,
                onPressed: () {},
              ),
              SizedBox(width: 36.w,),
              ControllerButton(
                iconSrc: StyleIconUrls.roomBottomMember,
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
              SizedBox(width: 36.w,),
              ControllerButton(
                iconSrc: StyleIconUrls.roomBottomGift,
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
              SizedBox(width: 36.w,),
              ControllerButton(
                iconSrc: StyleIconUrls.roomBottomSettings,
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
