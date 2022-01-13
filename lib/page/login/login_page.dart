import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live_audio_room_flutter/common/style/styles.dart';
import 'package:live_audio_room_flutter/model/zego_user_info.dart';
import 'package:live_audio_room_flutter/service/zego_user_service.dart';
import 'package:provider/src/provider.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class LoginPage extends HookWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userIdInputController = useTextEditingController();
    final userNameInputController = useTextEditingController();

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
                children: const [
                  Text('Zego Cloud',
                      style: StyleConstant.loginTitle,
                      textAlign: TextAlign.left),
                  Expanded(child: Text(''))
                ],
              ),
              Row(
                children: const [
                  Text('Live Audio Room',
                      style: StyleConstant.loginTitle,
                      textAlign: TextAlign.left),
                  Expanded(child: Text(''))
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
                decoration: const InputDecoration(
                    focusedBorder: textFormFieldBorder,
                    border: textFormFieldBorder,
                    hintStyle: StyleConstant.loginTextInputHintStyle,
                    hintText: 'User ID'),
                controller: userIdInputController,
              ),
              SizedBox(height: 49.h),
              TextFormField(
                style: StyleConstant.loginTextInput,
                decoration: const InputDecoration(
                    focusedBorder: textFormFieldBorder,
                    border: textFormFieldBorder,
                    hintStyle: StyleConstant.loginTextInputHintStyle,
                    hintText: 'User Name'),
                controller: userNameInputController,
              ),
              SizedBox(
                height: 70.h,
              ),
              ElevatedButton(
                child: const Text('Login'),
                style: ElevatedButton.styleFrom(
                  primary: StyleColors.blueButtonEnabledColor,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0)),
                  minimumSize: Size(630.w, 98.h),
                ),
                onPressed: () {
                  ZegoUserInfo info = ZegoUserInfo.empty();
                  info.userId = userIdInputController.text;
                  info.userName = userNameInputController.text;
                  var userModel = context.read<ZegoUserService>();
                  // TODO@oliver using correct token
                  userModel.login(
                      info,
                      "token",
                      (errorCode) => Navigator.pushReplacementNamed(
                          context, '/room_entrance'));
                },
              )
            ],
          ),
        ),
      ],
    )));
  }
}
