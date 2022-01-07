import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:live_audio_room_flutter/service/zego_user_service.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

typedef RoomOperationCallback = Function();

class CreateRoomDialog extends StatelessWidget {
  CreateRoomDialog({Key? key}) : super(key: key);

  final dialogRoomIDInputController = TextEditingController();
  final dialogRoomNameInputController = TextEditingController();

  void tryCreateRoom(RoomOperationCallback? callback) {
    if (dialogRoomIDInputController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter the roomid.");
      return;
    }
    if (dialogRoomNameInputController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter the room name.");
      return;
    }
    // TODO@oliveryang@zego.im call sdk and wait for callback to show the taost below.
    // The room has been created. Please join the room directly.
    // Failed to create. Error code: xx.
    // TODO@oliveryang@zego.im go to seats page while call sdk succeed.
    if (callback != null) {
      callback();
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return CupertinoAlertDialog(
      title: const Text("Create a new room"),
      content: FractionallySizedBox(
        widthFactor: 0.95,
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              height: 50,
              child: CupertinoTextField(
                expands: true,
                maxLines: null,
                maxLength: 20,
                placeholder: "Room ID",
                controller: dialogRoomIDInputController,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              height: 50,
              child: CupertinoTextField(
                expands: true,
                maxLines: null,
                maxLength: 16,
                placeholder: "Room Name",
                controller: dialogRoomNameInputController,
              ),
            ),
            const SizedBox(
              height: 10,
            )
          ],
        ),
      ),
      actions: [
        CupertinoDialogAction(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        CupertinoDialogAction(
          child: const Text('Create'),
          isDestructiveAction: true,
          onPressed: () {
            tryCreateRoom(
                () => Navigator.pushReplacementNamed(context, "/room_seats"));
          },
        )
      ],
    );
  }
}

class RoomEntrancePage extends StatelessWidget {
  RoomEntrancePage({Key? key}) : super(key: key);

  final roomIDInputController = TextEditingController();

  void tryJoinRoom(RoomOperationCallback? callback) {
    if (roomIDInputController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter the roomid.");
      return;
    }
    // TODO@oliveryang@zego.im join room by calling sdk and call callback after finished.
    // The room does not exist. Please create a new one.
    // Failed to join. Error code: xx.
    if (callback != null) {
      callback();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
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
            SizedBox(
              height: 50,
              child: CupertinoTextField(
                expands: true,
                maxLines: null,
                maxLength: 20,
                placeholder: "Room ID",
                controller: roomIDInputController,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            CupertinoButton.filled(
                child: const Text("Join Room"),
                onPressed: () {
                  tryJoinRoom(() =>
                      Navigator.pushReplacementNamed(context, "/room_seats"));
                }),
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
                onPressed: () {
                  showCupertinoDialog<void>(
                      context: context,
                      builder: (BuildContext context) => CreateRoomDialog());
                }),
          ],
        ),
      ),
    ));

    // return Scaffold(
    //   body: Center(
    //     child: Consumer<UserService>(
    //         builder: (context, user, child) =>
    //             Text('Welcome ${user.localUserInfo.userName}', style: Theme.of(context).textTheme.bodyText1)),
    //   ),
    // );
  }
}
