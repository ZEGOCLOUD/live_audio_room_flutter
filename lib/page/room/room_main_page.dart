import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:live_audio_room_flutter/common/toast_content.dart';
import 'package:provider/provider.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_provider_utilities/flutter_provider_utilities.dart';

import 'package:live_audio_room_flutter/service/zego_room_service.dart';
import 'package:live_audio_room_flutter/service/zego_user_service.dart';
import 'package:live_audio_room_flutter/service/zego_message_service.dart';
import 'package:live_audio_room_flutter/model/zego_user_info.dart';

import 'package:live_audio_room_flutter/page/room/room_center_content_frame.dart';
import 'package:live_audio_room_flutter/page/room/room_control_buttons_bar.dart';
import 'package:live_audio_room_flutter/page/room/room_title_bar.dart';
import 'package:flutter_gen/gen_l10n/live_audio_room_localizations.dart';
import 'package:live_audio_room_flutter/model/zego_room_user_role.dart';

class RoomMainPage extends StatelessWidget {
  const RoomMainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Center(
        child: Container(
          color: const Color(0xFFF4F4F6),
          // padding: const EdgeInsets.all(80.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 16.h,
              ),
              const RoomTitleBar(),
              const Expanded(child: RoomCenterContentFrame()),
              const RoomControlButtonsBar(),
              //  room toast tips
              Offstage(
                  offstage: true,
                  child: MessageListener<ZegoRoomService>(
                    child: const Text(''),
                    showError: (error) {},
                    showInfo: (jsonInfo) {
                      var toastContent =
                          RoomToastContent.fromJson(jsonDecode(jsonInfo));

                      switch (toastContent.toastType) {
                        case RoomToastType.textMessageDisable:
                          _showTextMessageTips(context, toastContent);
                          break;
                        case RoomToastType.roomEndByHost:
                          _showRoomEndByHostTips(context, toastContent);
                          break;
                        case RoomToastType.roomNetworkLeave:
                          break;
                      }
                    },
                  )),
            ],
          ),
        ),
      ),
    ));
  }

  _showTextMessageTips(BuildContext context, RoomToastContent toastContent) {
    if (toastContent.toastType != RoomToastType.textMessageDisable) {
      return;
    }

    var isTextMessageDisable = toastContent.message.toLowerCase() == 'true';
    String message;
    if (isTextMessageDisable) {
      message = AppLocalizations.of(context)!.toastDisableTextChatTips;
    } else {
      message = AppLocalizations.of(context)!.toastAllowTextChatTips;
    }

    Fluttertoast.showToast(msg: message, backgroundColor: Colors.grey);
  }

  _showRoomEndByHostTips(BuildContext context, RoomToastContent toastContent) {
    if (toastContent.toastType != RoomToastType.roomEndByHost) {
      return;
    }

    var title = Text(AppLocalizations.of(context)!.dialogTipsTitle,
        textAlign: TextAlign.center);
    var content = Text(AppLocalizations.of(context)!.toastRoomHasDestroyed,
        textAlign: TextAlign.center);

    var alert = AlertDialog(
      title: title,
      content: content,
      actions: <Widget>[
        TextButton(
          child: Text(AppLocalizations.of(context)!.dialogConfirm,
              textAlign: TextAlign.center),
          onPressed: () {
            Navigator.of(context).pop(true);
            Navigator.pushReplacementNamed(context, "/room_entrance");
          },
        ),
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
