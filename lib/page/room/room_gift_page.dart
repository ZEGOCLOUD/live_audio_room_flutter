import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:live_audio_room_flutter/common/style/styles.dart';
import 'package:live_audio_room_flutter/model/zego_user_info.dart';
import 'package:live_audio_room_flutter/model/zego_room_user_role.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RoomGiftBottomBar extends StatefulWidget {
  const RoomGiftBottomBar({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RoomGiftBottomBarState();
  }
}

class _RoomGiftBottomBarState extends State<RoomGiftBottomBar> {
  final List<ZegoUserInfo> _users = [
    ZegoUserInfo('0001', 'Liam', ZegoRoomUserRole.roomUserRoleHost),
    ZegoUserInfo('0002', 'Noah', ZegoRoomUserRole.roomUserRoleSpeaker),
    ZegoUserInfo('0003', 'Oliver', ZegoRoomUserRole.roomUserRoleSpeaker),
    ZegoUserInfo('0004', 'William', ZegoRoomUserRole.roomUserRoleListener),
    ZegoUserInfo('0005', 'Elijah', ZegoRoomUserRole.roomUserRoleListener),
    ZegoUserInfo('0006', 'James', ZegoRoomUserRole.roomUserRoleListener),
    ZegoUserInfo('0007', 'Benjamin', ZegoRoomUserRole.roomUserRoleListener),
    ZegoUserInfo('0008', 'Lucas', ZegoRoomUserRole.roomUserRoleListener),
    ZegoUserInfo('0009', 'Mason', ZegoRoomUserRole.roomUserRoleListener),
    ZegoUserInfo('0010', 'Ethan', ZegoRoomUserRole.roomUserRoleListener),
    ZegoUserInfo('0011', 'Alexander', ZegoRoomUserRole.roomUserRoleListener)
  ];

  final userNameInputController = TextEditingController();

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
              padding: EdgeInsets.only(
                  left: 36.w, top: 0, right: 0, bottom: 3 /*magic num.*/),
              child: Row(
                children: [
                  SizedBox(
                      width: 318.w,
                      height: 80.h,
                      child: Center(
                          child: TextFormField(
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        style: StyleConstant.roomGiftInputText,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintStyle: StyleConstant.roomGiftInputText,
                            hintText: 'Choose a member on mic'),
                        controller: userNameInputController,
                      ))),
                  const Expanded(child: Text('')),
                  PopupMenuButton(
                      elevation: 5,
                      icon: Image.asset(StyleIconUrls.roomMemberDropDownArrow),
                      padding: const EdgeInsets.all(5),
                      shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      onSelected: (String value) {
                        setState(() {
                          userNameInputController.text = value;
                        });
                      },
                      itemBuilder: (context) {
                        return _users.map((ZegoUserInfo userInfo) {
                          return PopupMenuItem(
                            height: 84.h,
                            value: userInfo.userName,
                            child: SizedBox(
                                width: 468.0.w, child: Text(userInfo.userName)),
                          );
                        }).toList();
                      })
                ],
              )),
          SizedBox(
              width: 188.w,
              height: 80.h,
              child: OutlinedButton(
                onPressed: () {
                  //  todo@yuyj send gift logic
                },
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
      decoration:
          const BoxDecoration(color: StyleColors.roomPopUpPageBackgroundColor),
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
