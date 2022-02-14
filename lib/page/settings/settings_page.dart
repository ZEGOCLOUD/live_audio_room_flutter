import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:live_audio_room_flutter/service/zego_room_manager.dart';
import 'package:live_audio_room_flutter/service/zego_user_service.dart';

import 'package:live_audio_room_flutter/constants/zego_page_constant.dart';
import 'package:live_audio_room_flutter/common/style/styles.dart';
import 'package:flutter_gen/gen_l10n/live_audio_room_localizations.dart';

class SettingSDKVersionWidget extends StatelessWidget {
  final String title;
  final String content;

  const SettingSDKVersionWidget(
      {required this.title, required this.content, Key? key})
      : super(key: key);

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
    return Container(
        decoration: const BoxDecoration(
          color: StyleColors.settingsCellBackgroundColor,
        ),
        padding: EdgeInsets.only(left: 32.w, top: 0, right: 32.w, bottom: 0),
        child: SizedBox(
            height: 98.h,
            child: Row(children: [
              Text(title,
                  style: StyleConstant.settingTitle,
                  textDirection: TextDirection.ltr),
              const Expanded(
                child: Text(''),
              ),
              Text(content,
                  style: StyleConstant.settingVersion,
                  textDirection: TextDirection.rtl)
            ])));
  }
}

class SettingsUploadLogWidget extends StatelessWidget {
  const SettingsUploadLogWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          color: StyleColors.settingsCellBackgroundColor,
        ),
        padding: EdgeInsets.only(left: 32.w, top: 0, right: 32.w, bottom: 0),
        margin: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 120.h),
        child: SizedBox(
            height: 98.h,
            child: InkWell(
              onTap: () {
                ZegoRoomManager.shared.uploadLog().then((errorCode) {
                  if (0 != errorCode) {
                    Fluttertoast.showToast(
                        msg: AppLocalizations.of(context)!
                            .toastUploadLogFail(errorCode),
                        backgroundColor: Colors.grey);
                  } else {
                    Fluttertoast.showToast(
                        msg:
                            AppLocalizations.of(context)!.toastUploadLogSuccess,
                        backgroundColor: Colors.grey);
                  }
                });
              },
              child: Row(
                children: [
                  Text(AppLocalizations.of(context)!.settingPageUploadLog,
                      style: StyleConstant.settingTitle,
                      textDirection: TextDirection.ltr),
                  const Expanded(
                    child: Text(''),
                  )
                ],
              ),
            )));
  }
}

class SettingsLogoutWidget extends StatelessWidget {
  const SettingsLogoutWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
          height: 98.h,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: StyleColors.settingsCellBackgroundColor,
          ),
          child: Center(
              child: Text(AppLocalizations.of(context)!.settingPageLogout,
                  textAlign: TextAlign.center,
                  style: StyleConstant.settingLogout))),
      onTap: () {
        var userService = context.read<ZegoUserService>();
        userService.logout().then((errorCode) {
          if (0 != errorCode) {
            Fluttertoast.showToast(
                msg: AppLocalizations.of(context)!.toastLogoutFail(errorCode),
                backgroundColor: Colors.grey);
          }
        });
        Navigator.pushReplacementNamed(context, PageRouteNames.login);
      },
    );
  }
}

class SettingsPage extends HookWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var expressSDKVersion = useState('1.0');
    ZegoExpressEngine.getVersion()
        .then((value) => expressSDKVersion.value = value);
    final zimSDKVersion = useState('1.0');
    ZegoRoomManager.shared
        .getZimVersion()
        .then((version) => zimSDKVersion.value = version);
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
              icon: Image.asset(StyleIconUrls.navigatorBack),
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, PageRouteNames.roomEntrance)),
          title: Text(AppLocalizations.of(context)!.settingPageSettings,
              style: StyleConstant.settingAppBar,
              textDirection: TextDirection.ltr),
          centerTitle: true,
          backgroundColor: StyleColors.settingsTitleBackgroundColor,
        ),
        body: SafeArea(
          child: Container(
              decoration: const BoxDecoration(
                  color: StyleColors.settingsBackgroundColor),
              child: Column(children: [
                // sdk version
                Container(
                    margin: EdgeInsets.only(
                        left: 0, top: 32.h, right: 0, bottom: 20.h),
                    child: Column(
                      children: [
                        SettingSDKVersionWidget(
                            title: AppLocalizations.of(context)!
                                .settingPageSdkVersion,
                            content: expressSDKVersion.value),
                        SettingSDKVersionWidget(
                            title: AppLocalizations.of(context)!
                                .settingPageZimSdkVersion,
                            content: zimSDKVersion.value)
                      ]
                          .map((e) => Padding(
                                child: e,
                                padding: EdgeInsets.symmetric(vertical: 2.h),
                              ))
                          .toList(),
                    )),
                // log version
                const SettingsUploadLogWidget(),
                // logout
                const SettingsLogoutWidget()
              ])),
        ));
  }
}
