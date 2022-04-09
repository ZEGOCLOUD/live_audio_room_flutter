import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_provider_utilities/flutter_provider_utilities.dart';

import '../../service/zego_room_service.dart';
import '../../service/zego_user_service.dart';

import '../../constants/zego_page_constant.dart';
import '../../constants/zim_error_code.dart';
import '../../common/room_info_content.dart';
import '../../model/zego_room_user_role.dart';
import '../../page/room/create_room_dialog.dart';
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
    room.joinRoom(roomID).then((code) {
      if (code != 0) {
        String message = AppLocalizations.of(context)!.toastJoinRoomFail(code);
        if (code == ZIMErrorCodeExtension.valueMap[zimErrorCode.roomNotExist]) {
          message = AppLocalizations.of(context)!.toastRoomNotExistFail;
        }
        Fluttertoast.showToast(msg: message, backgroundColor: Colors.grey);
      } else {
        var users = context.read<ZegoUserService>();
        if (room.roomInfo.hostID == users.localUserInfo.userID) {
          users.localUserInfo.userRole = ZegoRoomUserRole.roomUserRoleHost;
        }

        Navigator.pushReplacementNamed(context, PageRouteNames.roomMain);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: _mainWidget(context),
    );
  }

  Widget _mainWidget(BuildContext context) {
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
                  onPressed: () => Navigator.pushReplacementNamed(
                      context, PageRouteNames.settings),
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
            Consumer<ZegoUserService>(builder: (_, userService, child) {
              if (userService.notifyInfo.isEmpty) {
                return const Offstage(offstage: true, child: Text(''));
              }
              Future.delayed(Duration.zero, () async {
                var infoContent = RoomInfoContent.fromJson(
                    jsonDecode(userService.notifyInfo));

                switch (infoContent.toastType) {
                  case RoomInfoType.loginUserKickOut:
                    _showLoginUserKickOutTips(context, infoContent);
                    break;
                  default:
                    break;
                }
              });

              return const Offstage(offstage: true, child: Text(''));
            }),
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
    Navigator.pushReplacementNamed(context, PageRouteNames.login);
  }
}
