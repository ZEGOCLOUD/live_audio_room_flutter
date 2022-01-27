import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_provider_utilities/flutter_provider_utilities.dart';

import 'package:live_audio_room_flutter/service/zego_room_service.dart';
import 'package:live_audio_room_flutter/service/zego_user_service.dart';

import 'package:live_audio_room_flutter/common/room_info_content.dart';
import 'package:live_audio_room_flutter/model/zego_room_user_role.dart';
import 'package:live_audio_room_flutter/page/room/create_room_dialog.dart';
import 'package:flutter_gen/gen_l10n/live_audio_room_localizations.dart';

class RoomEntrancePage extends HookWidget {
  const RoomEntrancePage({Key? key}) : super(key: key);

  void tryJoinRoom(BuildContext context, String roomID) {
    if (roomID.isEmpty) {
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.toastRoomIdEnterError,
          backgroundColor: Colors.grey);
      return;
    }

    var room = context.read<ZegoRoomService>();
    room.joinRoom(roomID, "").then((code) {
      if (code != 0) {
        String message = AppLocalizations.of(context)!.toastJoinRoomFail(code);
        if (6000301 == code) {
          message = AppLocalizations.of(context)!.toastRoomNotExistFail;
        }
        Fluttertoast.showToast(msg: message, backgroundColor: Colors.grey);
      } else {
        var users = context.read<ZegoUserService>();
        if (room.roomInfo.hostID == users.localUserInfo.userID) {
          users.localUserInfo.userRole = ZegoRoomUserRole.roomUserRoleHost;
        }

        Navigator.pushReplacementNamed(context, "/room_main");
      }
    });
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
                  child:
                      Text(AppLocalizations.of(context)!.settingPageSettings),
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
                placeholder: AppLocalizations.of(context)!.createPageRoomId,
                controller: roomIDInputController,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            CupertinoButton.filled(
                child: Text(AppLocalizations.of(context)!.createPageJoinRoom),
                onPressed: () {
                  tryJoinRoom(context, roomIDInputController.text);
                }),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text(AppLocalizations.of(context)!.createPageOr)],
              ),
            ),
            CupertinoButton(
                color: Colors.blueGrey[50],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 24.0,
                    ),
                    Text(
                      AppLocalizations.of(context)!.createPageCreateRoom,
                      style: const TextStyle(color: Colors.black),
                    )
                  ],
                ),
                onPressed: () {
                  showCupertinoDialog<void>(
                      context: context,
                      builder: (BuildContext context) =>
                          const CreateRoomDialog());
                }),
            Offstage(
                offstage: true,
                child: MessageListener<ZegoUserService>(
                  child: const Text(''),
                  showError: (error) {},
                  showInfo: (jsonInfo) {
                    var infoContent =
                        RoomInfoContent.fromJson(jsonDecode(jsonInfo));

                    switch (infoContent.toastType) {
                      case RoomInfoType.loginUserKickOut:
                        _showLoginUserKickOutTips(context, infoContent);
                        break;
                      default:
                        break;
                    }
                  },
                )),
          ],
        ),
      ),
    )));
  }

  _showLoginUserKickOutTips(BuildContext context, RoomInfoContent infoContent) {
    if (infoContent.toastType != RoomInfoType.loginUserKickOut) {
      return;
    }

    Fluttertoast.showToast(
        msg: AppLocalizations.of(context)!.toastKickoutError,
        backgroundColor: Colors.grey);
    Navigator.pushReplacementNamed(context, "/login");
  }
}
