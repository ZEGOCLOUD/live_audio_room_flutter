import 'package:flutter/material.dart';
import 'package:live_audio_room_flutter/util/secret_reader.dart';

import 'package:provider/src/provider.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:live_audio_room_flutter/common/style/styles.dart';
import 'package:live_audio_room_flutter/model/zego_user_info.dart';
import 'package:live_audio_room_flutter/plugin/ZIMPlugin.dart';
import 'package:live_audio_room_flutter/service/zego_room_manager.dart';
import 'package:live_audio_room_flutter/service/zego_user_service.dart';
import 'package:live_audio_room_flutter/plugin/ZIMPlugin.dart';
import 'package:flutter_gen/gen_l10n/live_audio_room_localizations.dart';
import 'package:live_audio_room_flutter/common/device_info.dart';

class LoginPage extends HookWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userIdInputController = useTextEditingController();
    final userNameInputController = useTextEditingController();

    //  user id binding by device name
    final deviceName = useState('');
    userIdInputController.text = deviceName.value;
    DeviceInfo().readDeviceName().then((value) {
      deviceName.value = value;
    });

    // title
    final mainTitleText = useState('ZEGOCLOUD');
    final subTitleText = useState('Live Audio Room');
    var titleInfo = AppLocalizations.of(context)!.loginPageTitle.split('\n');
    if (2 == titleInfo.length) {
      //  default title if has not key
      mainTitleText.value = titleInfo[0];
      subTitleText.value = titleInfo[1];
    }

    const textFormFieldBorder = OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(24.0)),
        borderSide: BorderSide(
          color: StyleColors.loginTextBorderColor,
        ));

    return Scaffold(
        body: SafeArea(
            child: Column(
      children: [
        Container(
            margin: EdgeInsets.only(
                left: 74.w, top: 100.h, right: /*94*/ 0, bottom: 70.h),
            child: Column(children: [
              Row(
                children: [
                  Text(mainTitleText.value,
                      style: StyleConstant.loginTitle,
                      textAlign: TextAlign.left),
                  const Expanded(child: Text(''))
                ],
              ),
              Row(
                children: [
                  Text(subTitleText.value,
                      style: StyleConstant.loginTitle,
                      textAlign: TextAlign.left),
                  const Expanded(child: Text(''))
                ],
              ),
            ])),
        Container(
          margin:
              EdgeInsets.only(left: 60.w, top: 0, right: 60.w, bottom: 536.h),
          child: Column(
            children: [
              TextFormField(
                style: StyleConstant.loginTextInput,
                decoration: InputDecoration(
                    focusedBorder: textFormFieldBorder,
                    border: textFormFieldBorder,
                    hintStyle: StyleConstant.loginTextInputHintStyle,
                    hintText: AppLocalizations.of(context)!.loginPageUserId),
                controller: userIdInputController,
              ),
              SizedBox(height: 49.h),
              TextFormField(
                style: StyleConstant.loginTextInput,
                decoration: InputDecoration(
                    focusedBorder: textFormFieldBorder,
                    border: textFormFieldBorder,
                    hintStyle: StyleConstant.loginTextInputHintStyle,
                    hintText: AppLocalizations.of(context)!.loginPageUserName),
                controller: userNameInputController,
              ),
              SizedBox(
                height: 70.h,
              ),
              ElevatedButton(
                child: Text(AppLocalizations.of(context)!.loginPageLogin),
                style: ElevatedButton.styleFrom(
                  primary: StyleColors.blueButtonEnabledColor,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0)),
                  minimumSize: Size(630.w, 98.h),
                ),
                onPressed: () {
                  // WARNING: DO NOT USE APPID AND APPSIGN IN PRODUCTION CODE!!!GET IT FROM SERVER INSTEAD!!!
                  ZegoRoomManager.shared.initWithAPPID(
                      SecretReader.instance.appID,
                      SecretReader.instance.appSign, (errorCode) {
                    if (errorCode != 0) {
                      Fluttertoast.showToast(
                          msg: AppLocalizations.of(context)!
                              .toastLoginFail(errorCode));
                    }

                    ZegoUserInfo info = ZegoUserInfo.empty();
                    info.userID = userIdInputController.text;
                    info.userName = userNameInputController.text;
                    var userModel = context.read<ZegoUserService>();
                    userModel.login(info, "").then((errorCode) {
                      if (errorCode != 0) {
                        Fluttertoast.showToast(
                            msg: AppLocalizations.of(context)!
                                .toastLoginFail(errorCode));
                      }
                      Navigator.pushReplacementNamed(context, '/room_entrance');
                    });
                  });
                },
              )
            ],
          ),
        ),
      ],
    )));
  }
}
