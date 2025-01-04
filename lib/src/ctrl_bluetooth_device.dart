import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:the_last_bluetooth/src/utils.dart';

import 'android_bluetooth.g.dart' as jni;
import 'bluetooth_device.dart';

class CtrlBluetoothDevice implements BluetoothDevice {
  const CtrlBluetoothDevice(
    this.mac, {
    required this.nameCtrl,
    required this.aliasCtrl,
    required this.isConnectedCtrl,
    required this.uuidsCompleter,
    required this.batteryLevelCtrl,
  });

  /// Devices that randomize their MACs are currently out of scope of this
  /// library, and I just know too few about this. This will be a breaking
  /// change if it ever comes up
  @override
  final String mac;

  final BehaviorSubject<String> nameCtrl;
  final BehaviorSubject<String> aliasCtrl;
  final BehaviorSubject<bool> isConnectedCtrl;
  final Completer<Set<String>> uuidsCompleter;
  final BehaviorSubject<int> batteryLevelCtrl;

  void close() {
    nameCtrl.close();
    aliasCtrl.close();
    isConnectedCtrl.close();
    if (!uuidsCompleter.isCompleted) {
      uuidsCompleter.complete(<String>{});
    }
    batteryLevelCtrl.close();
  }

  @override
  ValueStream<String> get name => nameCtrl.stream;

  @override
  ValueStream<String> get alias => aliasCtrl.stream;

  // I have a problem with this
  // I'm not sure if I should abstract "stuff that doesn't work when not
  // connected" away to some sub-class, or leave it just not emitting/responding
  @override
  ValueStream<bool> get isConnected => isConnectedCtrl.stream;

  @override
  Future<Set<String>> get uuids => uuidsCompleter.future;

  @override
  ValueStream<int> get battery => batteryLevelCtrl.stream;

  static CtrlBluetoothDevice fromAndroidBluetoothDevice(
      jni.BluetoothDevice dev) {
    final (name, alias, uuids, battery) = (
      dev.getName()?.toDString(),
      dev.getAlias()?.toDString(),
      dev.getUuids()?.map((e) => e.toString().toLowerCase()).toSet(),
      jni.TheLastUtils.bluetoothDeviceBatteryLevel(dev)
    );
    return CtrlBluetoothDevice(
      dev.getAddress()!.toDString(),
      nameCtrl: name != null ? BehaviorSubject.seeded(name) : BehaviorSubject(),
      aliasCtrl:
          alias != null ? BehaviorSubject.seeded(alias) : BehaviorSubject(),
      isConnectedCtrl: BehaviorSubject.seeded(
          jni.TheLastUtils.isBluetoothDeviceConnected(dev)),
      uuidsCompleter:
          uuids != null ? (Completer()..complete(uuids)) : Completer(),
      batteryLevelCtrl:
          battery >= 0 ? BehaviorSubject.seeded(battery) : BehaviorSubject(),
    );
  }
}
