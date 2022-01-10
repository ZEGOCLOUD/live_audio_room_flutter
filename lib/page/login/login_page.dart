import 'package:flutter/material.dart';
import 'package:live_audio_room_flutter/common/style/styles.dart';
import 'package:live_audio_room_flutter/model/zego_user_info.dart';
import 'package:live_audio_room_flutter/service/zego_user_service.dart';
import 'package:provider/src/provider.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);
  final userIdInputController = TextEditingController();
  final userNameInputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const textFormFieldBorder = OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(
          color: StyleColors.loginTextBorderColor,
        ));

    return Scaffold(
        body: Column(
      children: [
        Container(
            margin:
                const EdgeInsets.only(left: 37, top: 50, right: 94, bottom: 35),
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
              const EdgeInsets.only(left: 30, top: 0, right: 30, bottom: 268),
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
              const SizedBox(height: 26),
              TextFormField(
                style: StyleConstant.loginTextInput,
                decoration: const InputDecoration(
                    focusedBorder: textFormFieldBorder,
                    border: textFormFieldBorder,
                    hintStyle: StyleConstant.loginTextInputHintStyle,
                    hintText: 'User Name'),
                controller: userNameInputController,
              ),
              const SizedBox(
                height: 35,
              ),
              ElevatedButton(
                child: const Text('Login'),
                style: ElevatedButton.styleFrom(
                  primary: StyleColors.loginButtonColor,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  minimumSize: const Size(315, 49),
                ),
                onPressed: () {
                  ZegoUserInfo info = ZegoUserInfo();
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
    ));
  }
}
