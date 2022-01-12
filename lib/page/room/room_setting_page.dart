import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:live_audio_room_flutter/common/style/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RoomSettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RoomSettingPageState();
  }
}

class _RoomSettingPageState extends State<RoomSettingPage> {
  bool _isProhibitBeASpeaker = false; // prohibit listeners being a speaker
  bool _isProhibitSendMessages = false; // prohibit others sending messages

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 18.w, top: 10.h, right: 18.w, bottom: 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
              height: 72.h,
              child: const Center(
                  child: Text('Settings',
                      style: StyleConstant.roomBottomPopUpTitle))),
          SizedBox(height: 20.h),
          SizedBox(
              height: 108.h,
              child: Row(
                children: [
                  const Text('Prohibit listeners being a speaker',
                      style: StyleConstant.roomSettingSwitchText),
                  const Expanded(child: Text('')),
                  Switch(
                    activeColor: StyleColors.switchActiveColor,
                    activeTrackColor: StyleColors.switchActiveTrackColor,
                    inactiveTrackColor: StyleColors.switchInactiveTrackColor,
                    value: _isProhibitBeASpeaker,
                    onChanged: (value) {
                      setState(() {
                        _isProhibitBeASpeaker = value;
                        //  todo@yuyj to prohibit listeners being a speaker
                      });
                    },
                  )
                ],
              )),
          SizedBox(
              height: 108.h,
              child: Row(
                children: [
                  const Text('Prohibit others sending messages'),
                  const Expanded(child: Text('')),
                  Switch(
                    activeColor: StyleColors.switchActiveColor,
                    activeTrackColor: StyleColors.switchActiveTrackColor,
                    inactiveTrackColor: StyleColors.switchInactiveTrackColor,
                    value: _isProhibitSendMessages,
                    onChanged: (value) {
                      setState(() {
                        _isProhibitSendMessages = value;
                        //  todo@yuyj to prohibit others sending messages
                      });
                    },
                  )
                ],
              )),
          const Expanded(child: Text(''))
        ],
      ),
    );
  }
}
