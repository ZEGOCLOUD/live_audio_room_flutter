import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:live_audio_room_flutter/common/style/styles.dart';
import 'package:flutter_gen/gen_l10n/live_audio_room_localizations.dart';

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
      decoration:
          const BoxDecoration(color: StyleColors.roomPopUpPageBackgroundColor),
      padding:
          EdgeInsets.only(left: 36.w, top: 20.h, right: 36.w, bottom: 20.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
              height: 72.h,
              width: double.infinity,
              child: Center(
                  child: Text(AppLocalizations.of(context)!.roomPageSettings,
                      style: StyleConstant.roomBottomPopUpTitle))),
          SizedBox(height: 20.h),
          SizedBox(
              height: 108.h,
              child: Row(
                children: [
                  Text(AppLocalizations.of(context)!.roomPageSetTakeSeat,
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

                        if (!value) {
                          Fluttertoast.showToast(
                              msg: AppLocalizations.of(context)!
                                  .roomPageSetTakeSeat);
                        }
                      });
                    },
                  )
                ],
              )),
          SizedBox(
              height: 108.h,
              child: Row(
                children: [
                  Text(AppLocalizations.of(context)!.roomPageSetSilence),
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

                        if (!value) {
                          Fluttertoast.showToast(
                              msg: AppLocalizations.of(context)!
                                  .roomPageSetSilence,
                              backgroundColor: Colors.grey);
                        }
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
