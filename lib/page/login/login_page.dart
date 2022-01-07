import 'package:flutter/material.dart';
import 'package:live_audio_room_flutter/model/user_info.dart';
import 'package:live_audio_room_flutter/model/user_service.dart';
import 'package:provider/src/provider.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);
  final userIdInputController = TextEditingController();
  final userNameInputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(80.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome',
                style: Theme.of(context).textTheme.headline1,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'User ID',
                ),
                controller: userIdInputController,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'User Name',
                ),
                controller: userNameInputController,
              ),
              const SizedBox(
                height: 24,
              ),
              ElevatedButton(
                child: const Text('Login'),
                onPressed: () {
                  UserInfo info = UserInfo();
                  info.userId = userIdInputController.text;
                  info.userName = userNameInputController.text;
                  var userModel = context.read<UserService>();
                  // TODO@oliver using correct token
                  userModel.login(
                      info,
                      "token",
                      (errorCode) => Navigator.pushReplacementNamed(
                          context, '/room_entrance'));
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.yellow,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
