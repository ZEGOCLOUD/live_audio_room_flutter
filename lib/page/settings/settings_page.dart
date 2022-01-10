import 'package:flutter/material.dart';
import 'package:live_audio_room_flutter/common/style/styles.dart';

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
        padding: const EdgeInsets.only(left: 16, top: 0, right: 16, bottom: 0),
        child: SizedBox(
            height: 49,
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
        padding: const EdgeInsets.only(left: 16, top: 0, right: 16, bottom: 0),
        margin: const EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 60),
        child: SizedBox(
            height: 49,
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
        height: 49,
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
              icon: Image.asset(StyleIconUrls.navigator_back),
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
                    margin: const EdgeInsets.only(
                        left: 0, top: 16, right: 0, bottom: 10),
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 1),
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
