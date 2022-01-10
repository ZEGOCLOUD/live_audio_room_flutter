import 'package:flutter/material.dart';

class SettingPageDisplayRow extends StatelessWidget {
  final String title;
  final String content;

  const SettingPageDisplayRow({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(title, textDirection: TextDirection.ltr),
      const Expanded(
        child: Text(''),
      ),
      Text(content, textDirection: TextDirection.rtl)
    ]);
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', textDirection: TextDirection.ltr),
      ),
      body: SafeArea(
        child: Column(
            children: [
              // sdk version
              Column(
                children: const [
                  //  TODO@yuyj get sdk version
                  SettingPageDisplayRow(
                      title: 'EXPRESS SDK Version', content: '2.8'),
                  SettingPageDisplayRow(
                      title: 'ZIM SDK Version', content: '1.1')
                ],
              ),
              // log version
              InkWell(
                onTap: () {
                  //  TODO@yuuyj call user logout logic
                },
                child: Row(
                  children: const [
                    Text('UploadLog'),
                    Expanded(
                      child: Text(''),
                    )
                  ],
                ),
              ),
              // space
              const SizedBox(height: 30),
              // logout
              InkWell(
                onTap: () {
                  //  TODO@yuuyj call user logout logic
                },
                child: const Text('Logout'),
              ),
            ]),
      ),
    );
  }
}
