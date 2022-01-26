import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:live_audio_room_flutter/common/room_info_content.dart';
import 'package:live_audio_room_flutter/service/zego_gift_service.dart';
import 'package:live_audio_room_flutter/service/zego_message_service.dart';
import 'package:live_audio_room_flutter/service/zego_speaker_seat_service.dart';
import 'package:provider/provider.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_provider_utilities/flutter_provider_utilities.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'package:live_audio_room_flutter/service/zego_room_service.dart';
import 'package:live_audio_room_flutter/service/zego_user_service.dart';
import 'package:live_audio_room_flutter/service/zego_loading_service.dart';

import 'package:live_audio_room_flutter/page/room/room_center_content_frame.dart';
import 'package:live_audio_room_flutter/page/room/room_control_buttons_bar.dart';
import 'package:live_audio_room_flutter/page/room/room_title_bar.dart';
import 'package:flutter_gen/gen_l10n/live_audio_room_localizations.dart';

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
              //  room toast tips notify in room service
              Offstage(
                  offstage: true,
                  child: MessageListener<ZegoRoomService>(
                    child: const Text(''),
                    showError: (error) {},
                    showInfo: (jsonInfo) {
                      var infoContent =
                          RoomInfoContent.fromJson(jsonDecode(jsonInfo));

                      switch (infoContent.toastType) {
                        case RoomInfoType.textMessageDisable:
                          _showTextMessageTips(context, infoContent);
                          break;
                        case RoomInfoType.roomEndByHost:
                          _showRoomEndByHostTips(context, infoContent);
                          break;
                        case RoomInfoType.roomLeave:
                          break;
                        default:
                          break;
                      }
                    },
                  )),
              // room toast tips notify in user service
              Offstage(
                  offstage: true,
                  child: MessageListener<ZegoUserService>(
                    child: const Text(''),
                    showError: (error) {},
                    showInfo: (jsonInfo) {
                      var infoContent =
                          RoomInfoContent.fromJson(jsonDecode(jsonInfo));

                      switch (infoContent.toastType) {
                        case RoomInfoType.roomNetworkTempBroken:
                          _showNetworkTempBrokenTips(context, infoContent);
                          break;
                        case RoomInfoType.roomNetworkReconnected:
                          _hideNetworkTempBrokenTips(context, infoContent);
                          break;
                        case RoomInfoType.roomNetworkReconnectedTimeout:
                          _showNetworkDisconnectTimeoutDialog(
                              context, infoContent);
                          break;
                        case RoomInfoType.loginUserKickOut:
                          _showLoginUserKickOutTips(context, infoContent);
                          break;
                        case RoomInfoType.roomHostInviteToSpeak:
                          _showHostInviteToSpeak(context);
                          break;
                        default:
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

  _showTextMessageTips(BuildContext context, RoomInfoContent infoContent) {
    if (infoContent.toastType != RoomInfoType.textMessageDisable) {
      return;
    }

    var isTextMessageDisable = infoContent.message.toLowerCase() == 'true';
    String message;
    if (isTextMessageDisable) {
      message = AppLocalizations.of(context)!.toastDisableTextChatTips;
    } else {
      message = AppLocalizations.of(context)!.toastAllowTextChatTips;
    }

    Fluttertoast.showToast(msg: message, backgroundColor: Colors.grey);
  }

  _showDialog(BuildContext context, String title, String description,
      {String? cancelButtonText,
      String? confirmButtonText,
      VoidCallback? confirmCallback}) {
    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context,
                cancelButtonText ?? AppLocalizations.of(context)!.dialogCancel),
            child: Text(confirmButtonText ??
                AppLocalizations.of(context)!.dialogCancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(
                  context, AppLocalizations.of(context)!.dialogConfirm);

              if (confirmCallback != null) {
                confirmCallback();
              }
            },
            child: Text(AppLocalizations.of(context)!.dialogConfirm),
          ),
        ],
      ),
    );
  }

  _showHostInviteToSpeak(BuildContext context) {
    _showDialog(context, AppLocalizations.of(context)!.dialogInvitionTitle,
        AppLocalizations.of(context)!.dialogInvitionDescrip,
        cancelButtonText: AppLocalizations.of(context)!.dialogRefuse,
        confirmButtonText: AppLocalizations.of(context)!.dialogAccept,
        confirmCallback: () {
      var seatService = context.read<ZegoSpeakerSeatService>();
      var validSpeakerIndex = -1;
      for (final seat in seatService.seatList) {
        if (seat.userID.isEmpty) {
          validSpeakerIndex = seat.seatIndex;
          break;
        }
      }
      if (validSpeakerIndex == -1) {
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.roomPageNoMoreSeatAvailable,
            backgroundColor: Colors.grey);
        return;
      }
      seatService.takeSeat(validSpeakerIndex).then((errorCode) {
        if (errorCode != 0) {
          Fluttertoast.showToast(
              msg: AppLocalizations.of(context)!
                  .toastTakeSpeakerSeatFail(errorCode),
              backgroundColor: Colors.grey);
        }
      });
    });
  }

  _showRoomEndByHostTips(BuildContext context, RoomInfoContent infoContent) {
    if (infoContent.toastType != RoomInfoType.roomEndByHost) {
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
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _showNetworkTempBrokenTips(
      BuildContext context, RoomInfoContent infoContent) {
    if (infoContent.toastType != RoomInfoType.roomNetworkTempBroken) {
      return;
    }

    context
        .read<ZegoLoadingService>()
        .uploadLoadingText(AppLocalizations.of(context)!.networkReconnect);
    context.loaderOverlay.show();
  }

  _hideNetworkTempBrokenTips(
      BuildContext context, RoomInfoContent infoContent) {
    if (infoContent.toastType != RoomInfoType.roomNetworkReconnected) {
      return;
    }
    context.loaderOverlay.hide();
  }

  _showNetworkDisconnectTimeoutDialog(
      BuildContext context, RoomInfoContent infoContent) {
    if (infoContent.toastType != RoomInfoType.roomNetworkReconnectedTimeout) {
      return;
    }

    var title = Text(AppLocalizations.of(context)!.networkConnectFailedTitle,
        textAlign: TextAlign.center);
    var content = Text(AppLocalizations.of(context)!.toastDisconnectTips,
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
            Navigator.pushReplacementNamed(context, "/login");
          },
        ),
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
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
