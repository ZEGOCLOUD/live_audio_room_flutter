import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:live_audio_room_flutter/service/zego_user_service.dart';
import 'package:provider/provider.dart';

class RoomEntrancePage extends StatelessWidget {
  const RoomEntrancePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Center(
      child: FractionallySizedBox(
        widthFactor: 0.85,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, "/settings"),
                  child: const Text("Settings"),
                )
              ],
            ),
            const SizedBox(
              height: 150,
            ),
            const SizedBox(
              height: 50,
              child: CupertinoTextField(
                expands: true,
                maxLines: null,
                placeholder: "Room ID",
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            CupertinoButton.filled(
                child: const Text("Join Room"), onPressed: () {}),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [Text("Or")],
              ),
            ),
            CupertinoButton(
                color: Colors.blueGrey[50],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 24.0,
                    ),
                    Text(
                      "Create Room",
                      style: TextStyle(color: Colors.black),
                    )
                  ],
                ),
                onPressed: () {}),
          ],
        ),
      ),
    )));
    // return Scaffold(
    //   body: Center(
    //     child: Consumer<UserService>(
    //         builder: (context, user, child) =>
    //             Text('Welcome ${user.localUserInfo.userName}', style: Theme.of(context).textTheme.bodyText1)),
    //   ),
    // );
  }
}
