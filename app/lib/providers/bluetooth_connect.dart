import 'dart:math';

import 'package:comein/main.dart';
import 'package:comein/providers/config_name_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:rxdart/rxdart.dart';
import 'dart:async';
import 'dart:collection';
import 'dart:convert';

final bluetoothController = BluetoothController();
final flutterBlue = FlutterBlue.instance;
// final snackbarController = SnackbarController();

class BluetoothConnect extends StatelessWidget {
  BluetoothConnect(String deviceName, {super.key}) {
    bluetoothController.setTargetDeviceName(deviceName);
  }

  @override
  Widget build(BuildContext context) {
    // snackbarController.stream.listen(
    //   (snack) {
    //     if (snack != null) {
    //       // ScaffoldMessenger.of(context).showSnackBar(snack);
    //     }
    //   },
    // );
    // bluetoothController.startScan();

    return StreamBuilder<int>(
      stream: bluetoothController.stream,
      initialData: 1,
      builder: (c, snapshot) {
        if (snapshot.data == 1) {
          return PlatformIconButton(
            icon: const Icon(Icons.bluetooth),
            // size: 32,
            onPressed: () => bluetoothController.startScan(),
          );
        } else if (snapshot.data == 2) {
          return PlatformIconButton(
            icon: const Icon(Icons.bluetooth_searching),
            // iconSize: 32,
            onPressed: () => bluetoothController.stopScan(),
          );
        } else if (snapshot.data == 3) {
          return PlatformIconButton(
            icon: const Icon(Icons.bluetooth_connected),
            // iconSize: 32,
            onPressed: () => bluetoothController.disconnect(),
          );
        } else {
          return PlatformIconButton(
            icon: const Icon(Icons.bluetooth_disabled),
            // iconSize: 32,
            onPressed: null,
            // onPressed: () => bluetoothController.showSnackbar(
            //     Icons.bluetooth_disabled, 'Turn on Bluetooth!'),
          );
        }
      },
    );
  }
}

class SnackbarController {
  final BehaviorSubject<SnackBar?> _controller = BehaviorSubject.seeded(null);
  String _lastMsg = "";

  ValueStream<SnackBar?> get stream => _controller.stream;
  SnackBar? get current => _controller.value;

  openSnackbar(SnackBar snackBar, String msg) {
    if (msg != _lastMsg) {
      _lastMsg = msg;
      _controller.add(snackBar);
    }
  }
}

final settings = ConfigNameController(deviceName);

class BluetoothConnector {
  final BehaviorSubject<int> _controller = BehaviorSubject.seeded(0);

  BluetoothDevice? device;

  bool isBtAvalible = false;
  bool isScanning = false;
  bool isConnected = false;
  bool isWriting = false;

  String _lastSnackbar = "";

  List<MapEntry<String, List<int>>>? msgStack = [];
  HashMap<String, BluetoothCharacteristic>? map;

  sendInit() async {}
  close() async {}

  BluetoothConnector() {
    settings.stream.listen((data) {
      // targetDeviceName = data;
    });
    initDevice();
  }

  ValueStream<int> get stream => _controller.stream;
  int? get current => _controller.value;

  Future<bool> validDevice(BluetoothDevice device) async {
    print(device.name);
    List<BluetoothService> services = await device.discoverServices();
    for (final service in services) {
      // Reads all characteristics
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        List<int> value = await c.read();
        print(value);
      }
    }
    return true;
  }

  void startScan() async {
    // Start scanning
    if (isScanning) return;
    flutterBlue.startScan(timeout: const Duration(seconds: 30));
    // Listen to scan results
    final subscription = flutterBlue.scanResults.listen((results) {
      // do something with scan results
      for (ScanResult r in results) {
        print('${r.device.name} found! rssi: ${r.rssi}');
        // validDevice(r.device);
        if (r.device.name == deviceName) {
          setDevice(r.device);
          flutterBlue.stopScan();
          isScanning = false;
          break;
        }
      }
    });
    // if (!isScanning) {
    //   for (final connected in await flutterBlue.connectedDevices) {
    //     print('Connected: ${connected.name}');
    //     setDevice(connected);
    //   }
    //   flutterBlue.startScan(timeout: const Duration(seconds: 16));
    // }
  }

  stopScan() async {
    if (!isScanning) return;
    flutterBlue.stopScan();
    isScanning = false;
  }

  disconnect() async {
    if (device != null) {
      showSnackbar(
          Icons.bluetooth_disabled, 'Disonnected from ${device?.name}');
      await device?.disconnect();
      close();

      map = null;
      device = null;
      isConnected = false;
      isScanning = false;

      calcState();
    }
  }

  setTargetDeviceName(String name) {
    // targetDeviceName = name;
  }

  Future<void> initDevice() async {
    flutterBlue.state.listen((data) {
      bool isAvalible = (data == BluetoothState.on);
      isBtAvalible = isAvalible;
      if (isAvalible) {
        // showSnackbar(Icons.bluetooth, 'Bluetooth is online again!');
      }
      calcState();
    });

    flutterBlue.isScanning.listen((data) {
      isScanning = data;
      if (kDebugMode) print(isScanning);
      calcState();
    });

    for (final connected in await flutterBlue.connectedDevices) {
      if (kDebugMode) print('Connected: ${connected.name}');
      setDevice(connected);
    }
    flutterBlue.scanResults.listen((scans) {
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
    if (kDebugMode) print(stage);
    _controller.add(stage);
  }

  Future<void> setScanResult(ScanResult scan) async {
    BluetoothDevice _device = scan.device;
    await setDevice(_device);
  }

  Future<void> setDevice(BluetoothDevice _device) async {
    if (_device.name == deviceName && device == null) {
      if (kDebugMode) print(_device.name);

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
          if (kDebugMode) {
            print('${c.serviceUuid} ${c.uuid} [$properties] found!');
          }
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
    parse(List<int> data) => String.fromCharCodes(data);
    subscribeService<String>(guid, controller, parse);
  }

  void subscribeServiceInt(String guid, StreamController<int> controller) {
    parse(List<int> data) => bytesToInteger(data);
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
      if (kDebugMode) print(map);
      if (characteristic != null) {
        return await characteristic.read();
      }
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

      if ((msgStack?.length ?? 0) > 0) {
        for (int i = 0; i < (msgStack?.length ?? 0); i++) {
          await writeCharacteristics(
              msgStack?[i].key ?? "", msgStack?[i].value ?? []);
        }
        msgStack = [];
      }
      isWriting = false;
    } else if (importand) {
      msgStack?.add(MapEntry(characteristicGuid, data));
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
      // snackbarController.openSnackbar(
      //   SnackBar(
      //     duration: const Duration(seconds: 1),
      //     content: Row(
      //       children: <Widget>[
      //         Icon(icon),
      //         Text(msg),
      //       ],
      //     ),
      //   ),
      //   msg,
      // );
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
  String _textfieldValue = "testing";
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
  void close() async {
    _textStream.close();
    _numberStream.close();
    _boolStream.close();
  }

  BluetoothController() : super();

  sendSliderValue(double slider) async {
    _sliderValue = slider;
    int value = (slider * 100).toInt();
    await writeServiceInt(SEND.INT, value, false);
  }

  sendTextFieldValue(String text) async {
    _textfieldValue = text;
    await writeServiceString(SEND.INT, text, true);
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
