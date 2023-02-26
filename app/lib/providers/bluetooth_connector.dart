import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:comein/models/data_model.dart';
import 'package:comein/providers/config_name_controller.dart';
import 'package:comein/providers/snackbar_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:convert';

class BluetoothConnector {
  final settings = getIt.get<ConfigNameController>();
  final snackbar = getIt.get<SnackbarController>();

  final BehaviorSubject<int> _controller = BehaviorSubject.seeded(0);

  BluetoothDevice? device;
  String? targetDeviceName;

  bool isBtAvalible = false;
  bool isScanning = false;
  bool isConnected = false;
  bool isWriting = false;

  String _lastSnackbar = "";

  List<MapEntry<String, List<int>>> msgStack = [];
  HashMap<String, BluetoothCharacteristic>? map;

  sendInit() async {}
  close() async {}

  BluetoothConnector() {
    settings.stream.listen((data) {
      targetDeviceName = data;
    });
    initDevice();
  }

  ValueStream<int> get stream => _controller.stream;
  int? get current => _controller.value;

  startScan() async {
    if (!isScanning) {
      (await FlutterBlue.instance.connectedDevices).forEach((connected) {
        setDevice(connected);
      });
      FlutterBlue.instance.startScan(timeout: Duration(seconds: 16));
    }
  }

  stopScan() async {
    if (isScanning) {
      FlutterBlue.instance.stopScan();
    }
  }

  disconnect() async {
    if (device != null) {
      showSnackbar(
          Icons.bluetooth_disabled, 'Disonnected from ${device?.name}');
      device?.disconnect();
      close();

      map = null;
      device = null;
      isConnected = false;
      isScanning = false;

      calcState();
    }
  }

  setTargetDeviceName(String name) {
    targetDeviceName = name;
  }

  Future<void> initDevice() async {
    FlutterBlue.instance.state.listen((data) {
      bool isAvalible = (data == BluetoothState.on);
      isBtAvalible = isAvalible;
      if (isAvalible) {
        // showSnackbar(Icons.bluetooth, 'Bluetooth is online again!');
      }
      calcState();
    });

    FlutterBlue.instance.isScanning.listen((data) {
      isScanning = data;
      print(isScanning);
      calcState();
    });

    (await FlutterBlue.instance.connectedDevices).forEach((connected) {
      print('Connected: ${connected.name}');
      setDevice(connected);
    });
    FlutterBlue.instance.scanResults.listen((scans) {
      for (var scan in scans) {
        setScanResult(scan);
      }
    });
  }

  void calcState() {
    int stage = 1; // waiting for scanning
    stage = (isScanning) ? 2 : stage; // searching
    stage = (isConnected) ? 3 : stage; // connected
    stage = (!isBtAvalible) ? 0 : stage; // not avalible
    print(stage);
    _controller.add(stage);
  }

  Future<void> setScanResult(ScanResult scan) async {
    BluetoothDevice device = scan.device;
    await setDevice(device);
  }

  Future<void> setDevice(BluetoothDevice _device) async {
    if (_device.name == targetDeviceName && device == null) {
      await _device.disconnect();
      await _device.connect();

      map = HashMap<String, BluetoothCharacteristic>();

      showSnackbar(Icons.bluetooth, 'Connected to ${_device.name}');
      device = _device;
      isConnected = true;
      calcState();

      List<BluetoothService> services = await _device.discoverServices();

      for (var service in services) {
        for (var c in service.characteristics) {
          map?[c.uuid.toString()] = c;
          bool read = c.properties.read;
          bool write = c.properties.write;
          bool notify = c.properties.notify;
          bool indicate = c.properties.indicate;
          String properties = "";
          properties += (read ? "R" : "") + (write ? "W" : "");
          properties += (notify ? "N" : "") + (indicate ? "I" : "");
          print('${c.serviceUuid} ${c.uuid} [$properties] found!');

          if (notify || indicate) {
            await c.setNotifyValue(true);
          }
        }
      }

      await sendInit();
    }
  }

  subscribeService<T>(String characteristicGuid, StreamController<T> controller,
      T Function(List<int>) parse) {
    if (map != null) {
      var characteristic = map?[characteristicGuid];
      if (characteristic != null) {
        Stream<List<int>> listener = characteristic.value;

        listener.listen((onData) {
          if (!controller.isClosed) {
            T value = parse(onData);
            controller.sink.add(value);
          }
        });
      }
    }
  }

  subscribeServiceString(
      String guid, StreamController<String> controller) async {
    var parse = (List<int> data) => String.fromCharCodes(data);
    subscribeService<String>(guid, controller, parse);
  }

  void subscribeServiceInt(String guid, StreamController<int> controller) {
    var parse = (List<int> data) => bytesToInteger(data);
    subscribeService<int>(guid, controller, parse);
  }

  void subscribeServiceBool(String guid, StreamController<bool> controller) {
    parse(List<int> data) {
      if (data.isNotEmpty) {
        return data[0] != 0 ? true : false;
      }
      return false;
    }

    subscribeService<bool>(guid, controller, parse);
  }

  Future<List<int>> readService(String characteristicGuid) async {
    if (map != null) {
      BluetoothCharacteristic? characteristic = map?[characteristicGuid];
      return await characteristic?.read() ?? [];
    }
    return [];
  }

  Future<void> writeServiceInt(
      String characteristicGuid, int value, bool importand) async {
    int byte1 = value & 0xff;
    int byte2 = (value >> 8) & 0xff;
    await writeService(characteristicGuid, [byte1, byte2], importand);
  }

  Future<void> writeServiceString(
      String characteristicGuid, String msg, bool importand) async {
    await writeService(characteristicGuid, utf8.encode(msg), importand);
  }

  Future<void> writeServiceBool(
      String characteristicGuid, bool value, bool importand) async {
    int byte = value ? 0x01 : 0x00;
    await writeService(characteristicGuid, [byte], importand);
  }

  Future<void> writeService(
      String characteristicGuid, List<int> data, bool importand) async {
    // print("$characteristicGuid $isWriting");
    if (!isWriting) {
      isWriting = true;
      await writeCharacteristics(characteristicGuid, data);

      if (msgStack.isNotEmpty) {
        for (int i = 0; i < msgStack.length; i++) {
          await writeCharacteristics(msgStack[i].key, msgStack[i].value);
        }
        msgStack = [];
      }
      isWriting = false;
    } else if (importand) {
      msgStack.add(MapEntry(characteristicGuid, data));
    }
  }

  Future<void> writeCharacteristics(
      String characteristicGuid, List<int> data) async {
    if (map != null) {
      var characteristic = map?[characteristicGuid];
      if (characteristic != null) {
        await characteristic.write(data);
        return;
      }
    }
  }

  void showSnackbar(IconData icon, String msg) {
    if (msg != _lastSnackbar) {
      snackbar.openSnackbar(
        SnackBar(
          duration: const Duration(seconds: 1),
          content: Row(
            children: <Widget>[
              Icon(icon),
              Text(msg),
            ],
          ),
        ),
        msg,
      );
    }
    _lastSnackbar = msg;
  }

  int bytesToInteger(List<int> bytes) {
    int value = 0;
    for (var i = 0, length = bytes.length; i < length; i++) {
      value += bytes[i] * pow(256, i).toInt();
    }
    return value;
  }
}

class RECIVE {
  static const SERVICE = 'f2f9a4de-ef95-4fe1-9c2e-ab5ef6f0d6e9';
  static const INT = 'e376bd46-0d9a-44ab-bb71-c262d06f60c7';
  static const BOOL = '5c409aab-50d4-42c2-bf57-430916e5eaf4';
  static const STRING = '9e8fafe1-8966-4276-a3a3-d0b00269541e';
}

class SEND {
  static const SERVICE = '1450dbb0-e48c-4495-ae90-5ff53327ede4';
  static const INT = 'ec693074-43fe-489d-b63b-94456f83beb5';
  static const BOOL = '45db5a06-5481-49ee-a8e9-10b411d73de7';
  static const STRING = '9393c756-78ea-4629-a53e-52fb10f9a63f';
}

class BluetoothController extends BluetoothConnector {
  double _sliderValue = 0;
  String _textfieldValue = "Hi";
  bool _buttonState = false;

  var _textStream = StreamController<String>();
  var _numberStream = StreamController<int>();
  var _boolStream = StreamController<bool>();

  @override
  sendInit() async {
    await sendSliderValue(_sliderValue);
    await sendTextFieldValue(_textfieldValue);
    await sendButtonPressed(_buttonState);
    subscribeServiceString(RECIVE.STRING, _textStream);
    subscribeServiceInt(RECIVE.INT, _numberStream);
    subscribeServiceBool(RECIVE.BOOL, _boolStream);
  }

  @override
  close() async {
    //_textStream.close();
    //_numberStream.close();
    //_boolStream.close();
  }

  BluetoothController() : super();

  sendSliderValue(double slider) async {
    _sliderValue = slider;
    int value = (slider * 100).toInt();
    await writeServiceInt(SEND.INT, value, false);
  }

  sendTextFieldValue(String text) async {
    _textfieldValue = text;
    await writeServiceString(SEND.STRING, text, true);
  }

  sendButtonPressed(bool state) async {
    _buttonState = state;
    await writeServiceBool(SEND.BOOL, state, true);
  }

  Stream<String> getStringStream() {
    return _textStream.stream;
  }

  Stream<int> getIntStream() {
    return _numberStream.stream;
  }

  Stream<bool> getBoolStream() {
    return _boolStream.stream;
  }
}
