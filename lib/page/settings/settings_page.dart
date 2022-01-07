import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget{
  const SettingsPage({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: const [
            Text(
              "Settings Page",
              textDirection: TextDirection.ltr,
            )
          ],
        ),
      ),
    );
  }
}