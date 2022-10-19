import 'package:flutter/services.dart';
import 'package:the_last_bluetooth/src/bluetooth_device.dart';

export './src/bluetooth_device.dart';

class TheLastBluetooth {
  static const String namespace = 'the_last_bluetooth';

  static final TheLastBluetooth _instance = TheLastBluetooth._();

  static TheLastBluetooth get instance => _instance;

  static const MethodChannel _methodChannel =
      MethodChannel('$namespace/methods');

  TheLastBluetooth._() {
    _methodChannel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        default:
          throw "Unknown method ${call.method}";
      }
    });
  }

  Future<bool> isAvailable() async =>
      await _methodChannel.invokeMethod<bool>('isAvailable') ?? false;

  Future<bool> isEnabled() async =>
      await _methodChannel.invokeMethod<bool>('isEnabled') ?? false;

  Future<String> get adapterName async =>
      await _methodChannel.invokeMethod<String>('getName') ?? "";

  Future<List<BluetoothDevice>> get pairedDevices async {
    final devs =
        await _methodChannel.invokeMethod<List>('getPairedDevices') ?? [];
    return devs.map((e) => BluetoothDevice.fromMap(e)).toList();
  }
}
