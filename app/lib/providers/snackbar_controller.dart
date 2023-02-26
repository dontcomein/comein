import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class SnackbarController {
  final BehaviorSubject<Widget> _controller = BehaviorSubject.seeded(Container());
  String? _lastMsg = "";

  ValueStream<Widget?> get stream => _controller.stream;
  Widget? get current => _controller.value;

  openSnackbar(Widget widget, String msg) {
    if (msg != _lastMsg) {
      _lastMsg = msg;
      _controller.add(widget);
    }
  }
}
