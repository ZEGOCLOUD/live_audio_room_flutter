import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:live_audio_room_flutter/model/zego_room_user_role.dart';
import 'package:live_audio_room_flutter/service/zego_room_service.dart';
import 'package:live_audio_room_flutter/service/zego_speaker_seat_service.dart';
import 'package:live_audio_room_flutter/service/zego_user_service.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

typedef RoomOperationCallback = Function(int);

class CreateRoomDialog extends HookWidget {
  CreateRoomDialog({Key? key}) : super(key: key);

  void tryCreateRoom(BuildContext context, String roomID, String roomName,
      RoomOperationCallback? callback) {
    if (roomID.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter the roomID.");
      return;
    }
    if (roomName.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter the room name.");
      return;
    }
    // TODO@oliveryang@zego.im call sdk and wait for callback to show the taost below.
    // The room has been created. Please join the room directly.
    // Failed to create. Error code: xx.
    // TODO@oliveryang@zego.im go to seats page while call sdk succeed.
    var room = context.read<ZegoRoomService>();
    room.createRoom(roomID, roomName, "token", callback);
  }

  @override
  Widget build(BuildContext context) {
    final dialogRoomIDInputController = useTextEditingController();
    final dialogRoomNameInputController = useTextEditingController();

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
                context,
                dialogRoomIDInputController.text,
                dialogRoomNameInputController.text,
                (code) =>
                    Navigator.pushReplacementNamed(context, "/room_main"));
          },
        )
      ],
    );
  }
}

class RoomEntrancePage extends HookWidget {
  const RoomEntrancePage({Key? key}) : super(key: key);

  void tryJoinRoom(
      BuildContext context, String roomID, RoomOperationCallback? callback) {
    if (roomID.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter the roomID.");
      return;
    }
    // TODO@oliveryang@zego.im join room by calling sdk and call callback after finished.
    // The room does not exist. Please create a new one.
    // Failed to join. Error code: xx.
    var room = context.read<ZegoRoomService>();
    room.joinRoom(roomID, "token", callback);
    var users = context.read<ZegoUserService>();
    if (room.roomInfo.hostId == users.localUserInfo.userId) {
      users.localUserInfo.userRole = ZegoRoomUserRole.roomUserRoleHost;
    }
    // TODO@oliveryang below code for UI test only
    var seats = context.read<ZegoSpeakerSeatService>();
    seats.generateFakeDataForUITest();
  }

  @override
  Widget build(BuildContext context) {
    final roomIDInputController = useTextEditingController();

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
                  tryJoinRoom(
                      context,
                      roomIDInputController.text,
                      (code) => Navigator.pushReplacementNamed(
                          context, "/room_main"));
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
    )));
  }
}
