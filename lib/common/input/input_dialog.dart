import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'input_widget.dart';

class InputDialog {
  static Future<String?> show(
      BuildContext context, TextEditingController editingController) async {
    return Navigator.of(context).push(InputOverlay(editingController));
  }
}

class InputOverlay extends ModalRoute<String> {
  InputOverlay(this.editingController) : super();

  TextEditingController editingController;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Color get barrierColor => const Color(0x01000000);

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return GestureDetector(
        onTapDown: (_) => Navigator.of(context).pop(),
        child: InputWidget(tempEditController: editingController));
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      ),
      child: child,
    );
  }
}
