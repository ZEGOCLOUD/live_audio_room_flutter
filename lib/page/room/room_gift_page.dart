import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:live_audio_room_flutter/common/style/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RoomGiftBottomBar extends StatelessWidget {
  const RoomGiftBottomBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80.w,
      width: double.infinity,
      child: Row(
        children: [
          Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: StyleColors.giftMemberListBackgroundColor,
                  style: BorderStyle.solid,
                  width: 1.0,
                ),
                color: StyleColors.giftMemberListBackgroundColor,
                borderRadius: BorderRadius.circular(24.0),
              ),
              width: 468.w,
              height: 80.h,
              child: Row(
                children: [
                  SizedBox(width: 30.w),
                  Text('TODO Listview'),
                  const Expanded(child: Text('')),
                  SizedBox(width: 64.w, height: double.infinity),
                  IconButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      icon: Image.asset(StyleIconUrls.roomMemberDropDownArrow),
                      onPressed: () {
                        //  todo@yuyj show/hide member list view
                      }),
                  SizedBox(width: 24.w)
                ],
              )),
          SizedBox(
              width: 188.w,
              height: 80.h,
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('Send',
                    style: StyleConstant.roomGiftSendButtonText),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith((states) {
                    // If the button is pressed, return green, otherwise blue
                    if (states.contains(MaterialState.disabled)) {
                      return StyleColors.blueButtonDisableColor;
                    }
                    return StyleColors.blueButtonEnabledColor;
                  }),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0))),
                ),
              ))
        ],
      ),
    );
  }
}

class RoomGiftSelector extends StatefulWidget {
  const RoomGiftSelector({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RoomGiftSelectorState();
  }
}

class _RoomGiftSelectorState extends State<RoomGiftSelector> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 566.h,
      //color: Colors.black,
      width: double.infinity,
      child: GridView.count(
        primary: false,
        physics: const ScrollPhysics(),
        padding: EdgeInsets.only(left: 0, top: 20.h, right: 0, bottom: 20.h),
        //crossAxisSpacing: 1.w,
        mainAxisSpacing: 0,
        crossAxisCount: 4,
        children: <Widget>[
          IconButton(
            icon: Image.asset(StyleIconUrls.roomGiftFingerHeart),
            onPressed: () {},
          )
        ],
      ),
    );
  }
}

class RoomGiftPage extends StatelessWidget {
  const RoomGiftPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(left: 36.w, top: 20.h, right: 36.w, bottom: 22.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
              height: 72.h,
              width: double.infinity,
              child: const Center(
                  child: Text('Gifts',
                      textAlign: TextAlign.center,
                      style: StyleConstant.roomBottomPopUpTitle))),
          const RoomGiftSelector(),
          const RoomGiftBottomBar()
        ],
      ),
    );
  }
}
