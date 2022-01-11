import 'package:flutter/material.dart';
import 'package:live_audio_room_flutter/common/style/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingSDKVersionWidget extends StatelessWidget {
  final String title;
  final String content;

  const SettingSDKVersionWidget({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
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
                //  TODO@yuuyj call user logout logic
              },
              child: Row(
                children: const [
                  Text('Upload Log',
                      style: StyleConstant.settingTitle,
                      textDirection: TextDirection.ltr),
                  Expanded(
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
    return Container(
        height: 98.h,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: StyleColors.settingsCellBackgroundColor,
        ),
        child: Center(
            child: InkWell(
          onTap: () {
            //  TODO@yuuyj call user logout logic
            Navigator.pushReplacementNamed(context, "/login");
          },
          child: const Text('Logout',
              textAlign: TextAlign.center, style: StyleConstant.settingLogout),
        )));
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Image.asset(StyleIconUrls.navigatorBack),
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, "/room_entrance")),
          title: const Text('Settings',
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
                      children: const [
                        //  TODO@yuyj get sdk version
                        SettingSDKVersionWidget(
                            title: 'EXPRESS SDK Version', content: '2.8'),
                        SettingSDKVersionWidget(
                            title: 'ZIM SDK Version', content: '1.1')
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
