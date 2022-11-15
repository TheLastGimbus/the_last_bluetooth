import 'dart:async';

import 'package:flutter/services.dart';
import 'package:the_last_bluetooth/src/bluetooth_adapter.dart';
import 'package:the_last_bluetooth/src/bluetooth_device.dart';

import 'src/bluetooth_connection.dart';

export './src/bluetooth_adapter.dart';
export './src/bluetooth_connection.dart';
export './src/bluetooth_device.dart';

class TheLastBluetooth {
  static const String namespace = 'the_last_bluetooth';

  static final TheLastBluetooth _instance = TheLastBluetooth._();

  static TheLastBluetooth get instance => _instance;

  static const MethodChannel _methodChannel =
      MethodChannel('$namespace/methods');

  static const EventChannel _ecAdapterInfo =
      EventChannel('$namespace/adapterInfo');
  static const EventChannel _ecPairedDevices =
      EventChannel('$namespace/pairedDevices');

  // @Shit
  // NOTE: For now, i literally support only one connection
  static const EventChannel _ecRfcomm = EventChannel('$namespace/rfcomm');
  StreamController<Uint8List>? _scRfcommInput;
  StreamController<Uint8List>? _scRfcommOutput;

  Stream<BluetoothAdapter>? _adapterInfoStream;
  Stream<List<BluetoothDevice>>? _devicesStream;

  TheLastBluetooth._() {
    _methodChannel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        default:
          throw "Unknown method ${call.method}";
      }
    });

    // @Shit
    _ecRfcomm
        .receiveBroadcastStream()
        .listen((event) => _scRfcommInput?.add(event));
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

  Stream<BluetoothAdapter> get adapterInfoStream {
    _adapterInfoStream ??= _ecAdapterInfo
        .receiveBroadcastStream()
        .map((event) => BluetoothAdapter.fromMap(event));
    return _adapterInfoStream!;
  }

  // Emits current state, but only on first listen
  // Because of this, StreamBuilders built after first (for example, on second
  // page) don't work until there's any update :/
  // I don't know what would be a good solution for this now - there isn't such
  // a thing as "myStream.latest" or smth. Figure this out later
  Stream<List<BluetoothDevice>> get pairedDevicesStream {
    _devicesStream ??= _ecPairedDevices.receiveBroadcastStream().map((event) {
      if (event is! List<Object?>) {
        throw 'WTF: $event is not List<Object?> - ${event.runtimeType} instead :/';
      }
      return event.map((d) => BluetoothDevice.fromMap(d as Map)).toList();
    });
    return _devicesStream!;
  }

  // @Shit
  Future<BluetoothConnection> connectRfcomm(BluetoothDevice device) async {
    await _methodChannel.invokeMethod('connectRfcomm', device.toMap());
    _scRfcommInput = StreamController();
    _scRfcommOutput = StreamController();
    _scRfcommOutput!.stream.listen(
        (event) => _methodChannel.invokeMethod("rfcommWrite", {"data": event}));
    return BluetoothConnection(_scRfcommInput!.stream, _scRfcommOutput!.sink);
  }
}
