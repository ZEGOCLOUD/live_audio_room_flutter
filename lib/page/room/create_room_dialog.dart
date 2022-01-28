import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:live_audio_room_flutter/service/zego_room_service.dart';

import 'package:live_audio_room_flutter/constants/zim_error_code.dart';
import 'package:flutter_gen/gen_l10n/live_audio_room_localizations.dart';

class CreateRoomDialog extends HookWidget {
  const CreateRoomDialog({Key? key}) : super(key: key);

  void tryCreateRoom(BuildContext context, String roomID, String roomName) {
    if (roomID.isEmpty) {
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.toastRoomIdEnterError,
          backgroundColor: Colors.grey);
      return;
    }
    if (roomName.isEmpty) {
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.toastRoomNameError,
          backgroundColor: Colors.grey);
      return;
    }
    var room = context.read<ZegoRoomService>();
    room.createRoom(roomID, roomName, "").then((code) {
      if (code != 0) {
        String message =
            AppLocalizations.of(context)!.toastCreateRoomFail(code);
        if(code == ZIMErrorCodeExtension.valueMap[zimErrorCode.createExistRoom]) {
          message = AppLocalizations.of(context)!.toastRoomExisted;
        }
        Fluttertoast.showToast(msg: message, backgroundColor: Colors.grey);
      } else {
        Navigator.pushReplacementNamed(context, "/room_main");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dialogRoomIDInputController = useTextEditingController();
    final dialogRoomNameInputController = useTextEditingController();

    // TODO: implement build
    return CupertinoAlertDialog(
      title: Text(AppLocalizations.of(context)!.createPageCreateRoom),
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
                placeholder: AppLocalizations.of(context)!.createPageRoomId,
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
                placeholder: AppLocalizations.of(context)!.createPageRoomName,
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
          child: Text(AppLocalizations.of(context)!.createPageCancel),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        CupertinoDialogAction(
          child: Text(AppLocalizations.of(context)!.createPageCreate),
          isDestructiveAction: true,
          onPressed: () {
            tryCreateRoom(context, dialogRoomIDInputController.text,
                dialogRoomNameInputController.text);
          },
        )
      ],
    );
  }
}
