import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

void main() {
  /// Optimization when screen refresh rate and display rate are inconsistent
  GestureBinding.instance?.resamplingEnabled = true;
  runZonedGuarded(() {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      Zone.current.handleUncaughtError(details.exception, details.stack!);
      print(details.toString());
      /// TODO@yuyj show error page
      return Center(
        child: Text(details.exception.toString() + "\n " + details.stack.toString()),
      );
    };
    runApp(
      const Center(
        child: Text(
          'ZEGOCLOUD Live Audio Room',
          textDirection: TextDirection.ltr,
        ),
      ),
    );
  }, (Object obj, StackTrace stack) {
    print(obj);
    print(stack);
  });
}
