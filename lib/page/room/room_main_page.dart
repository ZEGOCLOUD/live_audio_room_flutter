import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:live_audio_room_flutter/model/zego_room_user_role.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'package:live_audio_room_flutter/service/zego_room_service.dart';
import 'package:live_audio_room_flutter/service/zego_user_service.dart';
import 'package:live_audio_room_flutter/service/zego_loading_service.dart';
import 'package:live_audio_room_flutter/service/zego_speaker_seat_service.dart';

import 'package:live_audio_room_flutter/constants/zego_room_constant.dart';
import 'package:live_audio_room_flutter/constants/zego_page_constant.dart';
import 'package:live_audio_room_flutter/common/room_info_content.dart';
import 'package:live_audio_room_flutter/page/room/room_center_content_frame.dart';
import 'package:live_audio_room_flutter/page/room/room_control_buttons_bar.dart';
import 'package:live_audio_room_flutter/page/room/room_title_bar.dart';
import 'package:flutter_gen/gen_l10n/live_audio_room_localizations.dart';

class RoomMainPage extends HookWidget with WidgetsBindingObserver {
  RoomMainPage({Key? key}) : super(key: key);

  BuildContext? tempContext;
  ValueNotifier<bool> hasDialog = ValueNotifier<bool>(false);

  @override
  Future didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        //  to foreground
        if (tempContext != null) {
          //  check if room end when app in background
          var roomService = tempContext?.read<ZegoRoomService>();
          if (roomService != null && roomService.roomInfo.roomID.isEmpty) {
            RoomInfoContent infoContent = RoomInfoContent.empty();
            infoContent.toastType = RoomInfoType.roomEndByHost;
            _showRoomEndTips(tempContext!, infoContent);
          }
        }
        break;
      case AppLifecycleState.paused:
        //  to background
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    tempContext = context;
    useEffect(() {
      WidgetsBinding.instance?.addObserver(this);
      return () => WidgetsBinding.instance?.removeObserver(this);
    }, const []);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: _mainWidget(context),
    );
  }

  Widget _mainWidget(BuildContext context) {
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
              RoomTitleBar(),
              const Expanded(child: RoomCenterContentFrame()),
              RoomControlButtonsBar(),
              //  room toast tips notify in room service
              Consumer<ZegoRoomService>(builder: (_, roomService, child) {
                if (roomService.notifyInfo.isEmpty) {
                  return const Offstage(offstage: true, child: Text(''));
                }

                var infoContent = RoomInfoContent.fromJson(
                    jsonDecode(roomService.notifyInfo));

                // if mobile lock screen, page will receive after active
                // but room info had clear if room end after lock, so should
                // execute case statement
                var roomEndType =
                    infoContent.toastType == RoomInfoType.roomEndByHost ||
                        infoContent.toastType == RoomInfoType.roomNetworkLeave;
                if (roomService.roomInfo.roomID.isEmpty && !roomEndType) {
                  return const Offstage(offstage: true, child: Text(''));
                }
                Future.delayed(Duration.zero, () async {
                  switch (infoContent.toastType) {
                    case RoomInfoType.textMessageDisable:
                      roomService.clearNotifyInfo();
                      _showTextMessageTips(context, infoContent);
                      break;
                    case RoomInfoType.roomEndByHost:
                    case RoomInfoType.roomNetworkLeave:
                      roomService.clearNotifyInfo();
                      _showRoomEndTips(context, infoContent);
                      break;
                    case RoomInfoType.roomNetworkTempBroken:
                      if (hasDialog.value) {
                        hasDialog.value = false;
                        Navigator.pop(context);
                      }
                      _showNetworkTempBrokenTips(context, infoContent);
                      break;
                    case RoomInfoType.roomNetworkReconnected:
                      if (hasDialog.value) {
                        hasDialog.value = false;
                        Navigator.pop(context);
                      }
                      roomService.clearNotifyInfo();
                      _hideNetworkTempBrokenTips(context, infoContent);
                      break;
                    default:
                      break;
                  }
                });
                return const Offstage(offstage: true, child: Text(''));
              }),
              // room toast tips notify in user service
              Consumer<ZegoUserService>(builder: (_, userService, child) {
                if (userService.notifyInfo.isEmpty) {
                  return const Offstage(offstage: true, child: Text(''));
                }
                Future.delayed(Duration.zero, () async {
                  var infoContent = RoomInfoContent.fromJson(
                      jsonDecode(userService.notifyInfo));

                  //  do not popup, if page showing timeout/room end dialog
                  //  when this two conditions happen one
                  var roomService = context.read<ZegoRoomService>();
                  var canHideIfHaveDialog =
                      !userService.hadRoomReconnectedTimeout &&
                          !roomService.roomDisconnectSuccess;

                  switch (infoContent.toastType) {
                    case RoomInfoType.roomNetworkTempBroken:
                      if (canHideIfHaveDialog && hasDialog.value) {
                        hasDialog.value = false;
                        Navigator.pop(context);
                      }
                      _showNetworkTempBrokenTips(context, infoContent);
                      break;
                    case RoomInfoType.roomNetworkReconnected:
                      if (canHideIfHaveDialog && hasDialog.value) {
                        hasDialog.value = false;
                        Navigator.pop(context);
                      }
                      _hideNetworkTempBrokenTips(context, infoContent);
                      break;
                    case RoomInfoType.roomNetworkReconnectedTimeout:
                      userService.clearNotifyInfo();
                      _showNetworkDisconnectTimeoutDialog(context, infoContent);
                      break;
                    case RoomInfoType.loginUserKickOut:
                      _showLoginUserKickOutTips(context, infoContent);
                      break;
                    case RoomInfoType.roomHostInviteToSpeak:
                      userService.clearNotifyInfo();
                      _showHostInviteToSpeak(context);
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
      ),
    ));
  }

  _showTextMessageTips(BuildContext context, RoomInfoContent infoContent) {
    if (infoContent.toastType != RoomInfoType.textMessageDisable) {
      return;
    }

    var userService = context.read<ZegoUserService>();
    if (ZegoRoomUserRole.roomUserRoleHost ==
        userService.localUserInfo.userRole) {
      return; //  display only not host
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
    if (hasDialog.value) {
      hasDialog.value = false;
      Navigator.pop(context);
    }

    hasDialog.value = true;

    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              hasDialog.value = false;

              Navigator.pop(
                  context,
                  cancelButtonText ??
                      AppLocalizations.of(context)!.dialogCancel);
            },
            child: Text(
                cancelButtonText ?? AppLocalizations.of(context)!.dialogCancel),
          ),
          TextButton(
            onPressed: () {
              hasDialog.value = false;

              Navigator.pop(
                  context,
                  confirmButtonText ??
                      AppLocalizations.of(context)!.dialogConfirm);

              if (confirmCallback != null) {
                confirmCallback();
              }
            },
            child: Text(confirmButtonText ??
                AppLocalizations.of(context)!.dialogConfirm),
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
        confirmCallback: () async {
      var seatService = context.read<ZegoSpeakerSeatService>();

      var userService = context.read<ZegoUserService>();
      if (seatService.isUserInSeat(userService.localUserInfo.userID)) {
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.toastTakeSpeakerSeatFail(-1),
            backgroundColor: Colors.grey);
        return;
      }

      var validSpeakerIndex = -1;
      for (final seat in seatService.seatList) {
        if (seat.userID.isEmpty &&
            ZegoSpeakerSeatStatus.unTaken == seat.status) {
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

      var status = await Permission.microphone.request();
      seatService.setMicrophoneDefaultMute(!status.isGranted);

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

  _showRoomEndTips(BuildContext context, RoomInfoContent infoContent) {
    if (infoContent.toastType != RoomInfoType.roomEndByHost &&
        infoContent.toastType != RoomInfoType.roomNetworkLeave) {
      return;
    }

    var roomService = context.read<ZegoRoomService>();
    roomService.leaveRoom();

    var userService = context.read<ZegoUserService>();
    if (userService.hadRoomReconnectedTimeout) {
      return; //  do not popup, if page showing timeout dialog
    }

    hasDialog.value = true;

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
            var roomService = context.read<ZegoRoomService>();
            roomService.leaveRoom();

            hasDialog.value = false;

            Navigator.of(context).pop(true);
            Navigator.pushReplacementNamed(
                context, PageRouteNames.roomEntrance);
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

    var userService = context.read<ZegoUserService>();
    if (userService.hadRoomReconnectedTimeout) {
      return; //  do not popup, if page showing timeout dialog
    }

    context
        .read<ZegoLoadingService>()
        .updateLoadingText(AppLocalizations.of(context)!.networkReconnect);
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

    context.loaderOverlay.hide(); //  hide if loading

    var roomService = context.read<ZegoRoomService>();
    roomService.leaveRoom();

    var userService = context.read<ZegoUserService>();
    userService.logout();

    hasDialog.value = true;

    var title = Text(AppLocalizations.of(context)!.networkConnectFailedTitle,
        textAlign: TextAlign.center);
    var content = Text(AppLocalizations.of(context)!.networkConnectFailed,
        textAlign: TextAlign.center);

    var alert = AlertDialog(
      title: title,
      content: content,
      actions: <Widget>[
        TextButton(
          child: Text(AppLocalizations.of(context)!.dialogConfirm,
              textAlign: TextAlign.center),
          onPressed: () {
            hasDialog.value = false;

            var roomService = context.read<ZegoRoomService>();
            roomService.leaveRoom();

            var userService = context.read<ZegoUserService>();
            userService.logout();

            Navigator.of(context).pop(true);
            Navigator.pushReplacementNamed(context, PageRouteNames.login);
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
    Navigator.pushReplacementNamed(context, PageRouteNames.login);
  }
}
