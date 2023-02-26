import 'package:rxdart/rxdart.dart';

class ConfigNameController {
  late BehaviorSubject<String> _controller;

  ConfigNameController(String deviceName) {
    _controller = BehaviorSubject.seeded(deviceName);
  }

  ValueStream<String> get stream => _controller.stream;
  String? get current => _controller.value;

  setDeviceName(String name) {
    _controller.add(name);
  }
}
