import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_broadcasts/flutter_broadcasts.dart' as fb;
import 'package:jni/jni.dart';
import 'package:rxdart/rxdart.dart';
import 'package:the_last_bluetooth/src/android_bluetooth.g.dart' as android;

import 'src/bluetooth_device.dart';

class TheLastBluetooth {
  static final TheLastBluetooth _instance = TheLastBluetooth._();

  static TheLastBluetooth get instance => _instance;

  late android.BluetoothManager _manager;
  late android.BluetoothAdapter _adapter;

  // Our streams for user:
  final _isEnabledCtrl = BehaviorSubject<bool>();
  final _pairedDevicesCtrl = BehaviorSubject<Set<_BluetoothDevice>>();

  TheLastBluetooth._() {
    // TODO: maybe don't require permission to init plugin but gradually, huh??

    // this is some init stuff - maybe move this to manual init() dispose() ?
    final ctx = android.Context.fromRef(Jni.getCachedApplicationContext());
    _manager = android.BluetoothManager.fromRef(
      ctx
          .getSystemService(android.Context.BLUETOOTH_SERVICE.toJString())
          .reference,
    );
    _adapter = _manager.getAdapter();

    // emit devices when enabled, clear when disabled
    _isEnabledCtrl.listen((event) => event
        ? _pairedDevicesCtrl.add(
            _adapter
                .getBondedDevices()
                .map(
                  (dev) => _BluetoothDevice(
                    dev.getAddress().toDString(),
                    nameCtrl: BehaviorSubject.seeded(dev.getName().toDString()),
                    aliasCtrl:
                        BehaviorSubject.seeded(dev.getAlias().toDString()),
                    isConnectedCtrl: BehaviorSubject.seeded(
                        android.TheLastUtils.isBluetoothDeviceConnected(dev)),
                  ),
                )
                .toSet(),
          )
        : _pairedDevicesCtrl.add(<_BluetoothDevice>{}));
    _isEnabledCtrl.add(_adapter.isEnabled());

    fb.BroadcastReceiver receiver = fb.BroadcastReceiver(
      names: <String>[
        android.BluetoothAdapter.ACTION_STATE_CHANGED,
        android.BluetoothDevice.ACTION_BOND_STATE_CHANGED,
        android.BluetoothDevice.ACTION_ACL_CONNECTED,
        android.BluetoothDevice.ACTION_ACL_DISCONNECTED,
        android.BluetoothDevice.ACTION_NAME_CHANGED,
        android.BluetoothDevice.ACTION_ALIAS_CHANGED,
      ],
    );
    receiver.messages.listen((event) {
      switch (event) {
        // oh my god, Dart shines already <3
        // and we're not fully JNI yet :')
        case fb.BroadcastMessage(
            name: android.BluetoothAdapter.ACTION_STATE_CHANGED,
            data: {
              android.BluetoothAdapter.EXTRA_STATE: int state,
              android.BluetoothAdapter.EXTRA_PREVIOUS_STATE: int _,
            },
          ):
          switch (state) {
            case android.BluetoothAdapter.STATE_ON:
              _isEnabledCtrl.add(true);
              break;
            case android.BluetoothAdapter.STATE_OFF:
              _isEnabledCtrl.add(false);
              break;
          }
          break;
        case fb.BroadcastMessage(
            name: android.BluetoothDevice.ACTION_BOND_STATE_CHANGED,
            data: {
              android.BluetoothDevice.EXTRA_DEVICE: String mac,
              android.BluetoothDevice.EXTRA_BOND_STATE: int state,
              android.BluetoothDevice.EXTRA_PREVIOUS_BOND_STATE: int _,
            },
          ):
          final extraDev = _adapter.getRemoteDevice(mac.toJString());
          switch (state) {
            case android.BluetoothDevice.BOND_BONDED:
              _pairedDevicesCtrl.add(
                _pairedDevicesCtrl.value
                  ..add(
                    _BluetoothDevice(
                      mac,
                      nameCtrl: BehaviorSubject.seeded(
                          extraDev.getName().toDString()),
                      aliasCtrl: BehaviorSubject.seeded(
                          extraDev.getAlias().toDString()),
                      isConnectedCtrl: BehaviorSubject.seeded(
                          android.TheLastUtils.isBluetoothDeviceConnected(
                              extraDev)),
                    ),
                  ),
              );
              break;
            case android.BluetoothDevice.BOND_NONE:
              _pairedDevicesCtrl.add(
                _pairedDevicesCtrl.value
                  ..removeWhere((dev) {
                    if (dev.mac == mac) {
                      dev.nameCtrl.close();
                      dev.aliasCtrl.close();
                      dev.isConnectedCtrl.close();
                      return true;
                    } else {
                      return false;
                    }
                  }),
              );
              break;
          }
          break;
        case fb.BroadcastMessage(
            name: android.BluetoothDevice.ACTION_ACL_CONNECTED,
            data: {
              android.BluetoothDevice.EXTRA_DEVICE: String mac,
              android.BluetoothDevice.EXTRA_TRANSPORT: int _,
            },
          ):
          _pairedDevicesCtrl.value
              .firstWhereOrNull((dev) => dev.mac == mac)
              ?.isConnectedCtrl
              .add(true);
          break;
        case fb.BroadcastMessage(
            name: android.BluetoothDevice.ACTION_ACL_DISCONNECTED,
            data: {
              android.BluetoothDevice.EXTRA_DEVICE: String mac,
              android.BluetoothDevice.EXTRA_TRANSPORT: int _,
            },
          ):
          _pairedDevicesCtrl.value
              .firstWhereOrNull((dev) => dev.mac == mac)
              ?.isConnectedCtrl
              .add(false);
          break;
        case fb.BroadcastMessage(
            name: android.BluetoothDevice.ACTION_NAME_CHANGED,
            data: {
              android.BluetoothDevice.EXTRA_DEVICE: String mac,
              android.BluetoothDevice.EXTRA_NAME: String name,
            },
          ):
          _pairedDevicesCtrl.value
              .firstWhereOrNull((dev) => dev.mac == mac)
              ?.nameCtrl
              .add(name);
          break;
        case fb.BroadcastMessage(
            name: android.BluetoothDevice.ACTION_ALIAS_CHANGED,
            data: {
              android.BluetoothDevice.EXTRA_DEVICE: String mac,
            },
          ):
          final extraDev = _adapter.getRemoteDevice(mac.toJString());
          _pairedDevicesCtrl.value
              .firstWhereOrNull((dev) => dev.mac == mac)
              ?.aliasCtrl
              .add(extraDev.getAlias().toDString());
          break;
      }
    });
    receiver.start();
  }

  // maybetodo: Make this real ??
  ValueStream<bool> get isAvailable => Stream.value(true).shareValue();

  ValueStream<bool> get isEnabled => _isEnabledCtrl.stream;

  ValueStream<Set<BluetoothDevice>> get pairedDevices =>
      _pairedDevicesCtrl.stream;
}

class _BluetoothDevice implements BluetoothDevice {
  const _BluetoothDevice(
    this.mac, {
    required this.nameCtrl,
    required this.aliasCtrl,
    required this.isConnectedCtrl,
  });

  /// Devices that randomize their MACs are currently out of scope of this
  /// library, and I just know too few about this. This will be a breaking
  /// change if it ever comes up
  @override
  final String mac;

  final BehaviorSubject<String> nameCtrl;
  final BehaviorSubject<String> aliasCtrl;
  final BehaviorSubject<bool> isConnectedCtrl;

  @override
  ValueStream<String> get name => nameCtrl.stream;

  @override
  ValueStream<String> get alias => aliasCtrl.stream;

  // I have a problem with this
  // I'm not sure if I should abstract "stuff that doesn't work when not
  // connected" away to some sub-class, or leave it just not emitting/responding
  @override
  ValueStream<bool> get isConnected => isConnectedCtrl.stream;
}

extension on JString {
  /// just with [releaseOriginal] true by default
  String toDString({bool releaseOriginal = true}) =>
      toDartString(releaseOriginal: releaseOriginal);
}
