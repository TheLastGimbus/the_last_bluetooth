import 'dart:async';

import 'package:flutter/services.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:the_last_bluetooth/src/bluetooth_adapter.dart';
import 'package:the_last_bluetooth/src/bluetooth_device.dart';

import 'src/bluetooth_connection.dart';
import 'src/shit_utils.dart';

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

  // NOTE: For now, i literally support only one connection
  @Shit()
  static const EventChannel _ecRfcomm = EventChannel('$namespace/rfcomm');
  final Map<String, StreamSink<Uint8List>> _rfcommChannels = {};

  Stream<BluetoothAdapter>? _adapterInfoStream;
  Stream<List<BluetoothDevice>>? _devicesStream;

  TheLastBluetooth._() {
    _methodChannel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        default:
          throw "Unknown method ${call.method}";
      }
    });

    // @Shit()
    _ecRfcomm.receiveBroadcastStream().listen((event) {
      print("Rfcomm from android: $event");
      final String socketId = event['socketId'];
      if (_rfcommChannels.containsKey(socketId)) {
        if (event['closed'] == true) {
          _rfcommChannels[socketId]!.close();
          _rfcommChannels.remove(socketId);
        } else {
          _rfcommChannels[socketId]!.add(event['data']);
        }
      } else {
        print("No channel for socketId $socketId!");
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

  Future<BluetoothConnection> connectRfcomm(
      BluetoothDevice device, String serviceUUID) async {
    final socketId = (await _methodChannel.invokeMethod<String>(
        'connectRfcomm', {...device.toMap(), 'uuid': serviceUUID}))!;
    final input = StreamController<Uint8List>();
    final output = StreamController<Uint8List>();
    output.stream.listen((event) {
      print("rfcomm write from flutter: $socketId: $event");
      _methodChannel
          .invokeMethod("rfcommWrite", {"socketId": socketId, "data": event});
    });
    _rfcommChannels[socketId] = input.sink;
    return BluetoothConnection(
        StreamChannel.withGuarantees(input.stream, output.sink));
  }
}
