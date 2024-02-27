// ignore_for_file: constant_identifier_names
import 'dart:async';

import 'package:collection/collection.dart';
import 'package:jni/jni.dart';
import 'package:rxdart/rxdart.dart';
import 'package:the_last_bluetooth/src/android_bluetooth.g.dart' as android;

import 'src/bluetooth_device.dart';

class TheLastBluetooth {
  // secret commands 😋
  // ohhhh i fucking love android
  static const _ACTION_BATTERY_LEVEL_CHANGED =
      "android.bluetooth.device.action.BATTERY_LEVEL_CHANGED";
  static const _EXTRA_BATTERY_LEVEL =
      "android.bluetooth.device.extra.BATTERY_LEVEL";

  static final TheLastBluetooth _instance = TheLastBluetooth._();

  static TheLastBluetooth get instance => _instance;

  late android.BluetoothManager _manager;
  late android.BluetoothAdapter _adapter;

  // Our streams for user:
  final _isEnabledCtrl = BehaviorSubject<bool>();
  final _pairedDevicesCtrl = BehaviorSubject<Set<_BluetoothDevice>>();

  TheLastBluetooth._() {
    // TODO: maybe don't require permission to init plugin but gradually, huh??
    // TODO: DEVICES OFTEN "BLINK" ABOUT THEIR CONNECTION

    // this is some init stuff - maybe move this to manual init() dispose() ?
    Jni.initDLApi();
    final ctx = android.Context.fromRef(Jni.getCachedApplicationContext());

    _manager = android.BluetoothManager.fromRef(
      ctx
          .getSystemService(android.Context.BLUETOOTH_SERVICE.toJString())
          .reference,
    );
    _adapter = _manager.getAdapter();

    // emit devices when enabled, clear when disabled
    _isEnabledCtrl.listen((event) {
      if (event) {
        _pairedDevicesCtrl.add(
          _adapter
              .getBondedDevices()
              .map((dev) => _androidDevToDart(dev))
              .toSet(),
        );
      } else {
        _pairedDevicesCtrl.valueOrNull?.forEach((dev) => dev.close());
        _pairedDevicesCtrl.add(<_BluetoothDevice>{});
      }
    });
    // this will also nicely trigger listener above :)
    _isEnabledCtrl.add(_adapter.isEnabled());

    // Register receiver:
    final tlr = android.TheLastBroadcastReceiver.new1(
      android.BroadcastReceiverInterface.implement(
        android.$BroadcastReceiverInterfaceImpl(onReceive: onReceive),
      ),
    );
    final filter = android.IntentFilter();
    for (final action in [
      android.BluetoothAdapter.ACTION_STATE_CHANGED,
      android.BluetoothDevice.ACTION_BOND_STATE_CHANGED,
      android.BluetoothDevice.ACTION_ACL_CONNECTED,
      android.BluetoothDevice.ACTION_ACL_DISCONNECTED,
      android.BluetoothDevice.ACTION_NAME_CHANGED,
      android.BluetoothDevice.ACTION_ALIAS_CHANGED,
      _ACTION_BATTERY_LEVEL_CHANGED,
    ]) {
      filter.addAction(action.toJString());
    }
    ctx.registerReceiver(tlr, filter);
  }

  void onReceive(android.Context context, android.Intent intent) {
    switch (intent.getAction().toDString()) {
      case android.BluetoothAdapter.ACTION_STATE_CHANGED:
        final btState = intent.getIntExtra(
            android.BluetoothAdapter.EXTRA_STATE.toJString(), -1);
        switch (btState) {
          case android.BluetoothAdapter.STATE_ON:
            _isEnabledCtrl.add(true);
            break;
          case android.BluetoothAdapter.STATE_OFF:
            _isEnabledCtrl.add(false);
            break;
        }
        break;
      case android.BluetoothDevice.ACTION_BOND_STATE_CHANGED:
        final extraDev = _getExtraDev(intent);
        final bondState = intent.getIntExtra(
            android.BluetoothDevice.EXTRA_BOND_STATE.toJString(), -1);
        switch (bondState) {
          case android.BluetoothDevice.BOND_BONDED:
            _pairedDevicesCtrl.add(
              _pairedDevicesCtrl.value
                ..add(
                  _androidDevToDart(extraDev.dev),
                ),
            );
            break;
          case android.BluetoothDevice.BOND_NONE:
            _pairedDevicesCtrl.add(
              _pairedDevicesCtrl.value
                ..removeWhere((dev) {
                  if (dev.mac == extraDev.mac) {
                    dev.close();
                    return true;
                  } else {
                    return false;
                  }
                }),
            );
            break;
        }
        break;
      case android.BluetoothDevice.ACTION_ACL_CONNECTED:
        final extraDev = _getExtraDev(intent);
        _pairedDevicesCtrl.value
            .firstWhereOrNull((dev) => dev.mac == extraDev.mac)
            ?.isConnectedCtrl
            .add(true);
        break;
      case android.BluetoothDevice.ACTION_ACL_DISCONNECTED:
        final extraDev = _getExtraDev(intent);
        _pairedDevicesCtrl.value
            .firstWhereOrNull((dev) => dev.mac == extraDev.mac)
            ?.isConnectedCtrl
            .add(false);
        break;
      case android.BluetoothDevice.ACTION_NAME_CHANGED:
        final extraDev = _getExtraDev(intent);
        final name = intent
            .getStringExtra(android.BluetoothDevice.EXTRA_NAME.toJString())
            .toDString();
        _pairedDevicesCtrl.value
            .firstWhereOrNull((dev) => dev.mac == extraDev.mac)
            ?.nameCtrl
            .add(name);
        break;
      case android.BluetoothDevice.ACTION_ALIAS_CHANGED:
        final extraDev = _getExtraDev(intent);
        _pairedDevicesCtrl.value
            .firstWhereOrNull((dev) => dev.mac == extraDev.mac)
            ?.aliasCtrl
            .add(extraDev.dev.getAlias().toDString());
        break;
      case _ACTION_BATTERY_LEVEL_CHANGED:
        final extraDev = _getExtraDev(intent);
        final battery =
            intent.getIntExtra(_EXTRA_BATTERY_LEVEL.toJString(), -1);
        if (battery >= 0) {
          _pairedDevicesCtrl.value
              .firstWhereOrNull((dev) => dev.mac == extraDev.mac)
              ?.batteryLevelCtrl
              .addDistinct(battery);
        }
    }
  }

  ({String mac, android.BluetoothDevice dev}) _getExtraDev(
      android.Intent intent) {
    final extraDev = intent.getParcelableExtra(
      android.BluetoothDevice.EXTRA_DEVICE.toJString(),
      T: const android.$BluetoothDeviceType(),
    );
    return (mac: extraDev.getAddress().toDString(), dev: extraDev);
  }

  _BluetoothDevice _androidDevToDart(android.BluetoothDevice dev) {
    final uuids = dev.getUuids();
    final battery = android.TheLastUtils.bluetoothDeviceBatteryLevel(dev);
    return _BluetoothDevice(
      dev.getAddress().toDString(),
      nameCtrl: BehaviorSubject.seeded(dev.getName().toDString()),
      aliasCtrl: BehaviorSubject.seeded(dev.getAlias().toDString()),
      isConnectedCtrl: BehaviorSubject.seeded(
          android.TheLastUtils.isBluetoothDeviceConnected(dev)),
      uuidsCompleter: Completer()
        ..complete(
          Iterable.generate(
            uuids.length,
            (i) => uuids[i].toString(),
          ).toSet(),
        ),
      batteryLevelCtrl:
          battery >= 0 ? BehaviorSubject.seeded(battery) : BehaviorSubject(),
    );
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
}

extension on JString {
  /// just with [releaseOriginal] true by default
  String toDString({bool releaseOriginal = true}) =>
      toDartString(releaseOriginal: releaseOriginal);
}

extension TheLastSubject<T> on BehaviorSubject<T> {
  void addDistinct(T value) {
    if (valueOrNull != value) {
      add(value);
    }
  }
}
