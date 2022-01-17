import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:live_audio_room_flutter/common/style/styles.dart';
import 'package:live_audio_room_flutter/model/zego_user_info.dart';
import 'package:live_audio_room_flutter/model/zego_room_user_role.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/live_audio_room_localizations.dart';

class RoomGiftMemberList extends StatefulWidget {
  const RoomGiftMemberList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RoomGiftMemberListState();
  }
}

class _RoomGiftMemberListState extends State<RoomGiftMemberList> {
  //  todo@yuyuj this is some test data
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: StyleColors.giftMemberListBackgroundColor,
        borderRadius: BorderRadius.circular(17.0),
      ),
      child: ListView.builder(
        itemExtent: 84.h,
        padding: EdgeInsets.only(left: 30.w),
        itemCount: _users.length,
        itemBuilder: (_, index) {
          ZegoUserInfo user = _users[index];
          return GestureDetector(
              child: Center(
                child: Row(
                  children: [
                    Text(
                      user.userName,
                      textAlign: TextAlign.left,
                      style: StyleConstant.roomGiftMemberListText,
                    ),
                    const Expanded(child: Text(''))
                  ],
                ),
              ),
              onTap: () {
                //  todo@yuyj change input text, userNameInputController
              });
        },
      ),
    );
  }
}

class RoomGiftBottomBar extends StatefulWidget {
  const RoomGiftBottomBar({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RoomGiftBottomBarState();
  }
}

class _RoomGiftBottomBarState extends State<RoomGiftBottomBar> {
  final userNameInputController = TextEditingController();
  final roomGiftMemberList = false;

  late OverlayEntry _memberListEntry;
  late OverlayState _memberListState;
  bool _isMemberListVisible = false;

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Align(
        alignment: Alignment.center,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          child: Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                padding: EdgeInsets.only(
                    left: 36.w, top: 812.h, right: 246.w, bottom: 102.h),
                child: RoomGiftMemberList(),
              )),
          onTap: () {
            hideMemberList();
          },
        ),
      ),
    );
  }

  showMemberList() async {
    if (!_isMemberListVisible) {
      _memberListState = Overlay.of(context)!;
      _memberListEntry = _createOverlayEntry();
      _memberListState.insert(_memberListEntry);
      _isMemberListVisible = true;
    }
  }

  void hideMemberList() {
    _isMemberListVisible = false;
    _memberListEntry.remove();
  }

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
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintStyle: StyleConstant.roomGiftInputText,
                            hintText: AppLocalizations.of(context)!
                                .roomPageSelectDefault),
                        controller: userNameInputController,
                      ))),
                  const Expanded(child: Text('')),
                  IconButton(
                      onPressed: () => showMemberList(),
                      icon: Image.asset(StyleIconUrls.roomMemberDropDownArrow))
                ],
              )),
          SizedBox(
              width: 188.w,
              height: 80.h,
              child: OutlinedButton(
                onPressed: () {
                  //  todo@yuyj send gift logic
                },
                child: Text(AppLocalizations.of(context)!.roomPageSendGift,
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
              child: Center(
                  child: Text(AppLocalizations.of(context)!.roomPageGift,
                      textAlign: TextAlign.center,
                      style: StyleConstant.roomBottomPopUpTitle))),
          const RoomGiftSelector(),
          const RoomGiftBottomBar()
        ],
      ),
    );
  }
}
