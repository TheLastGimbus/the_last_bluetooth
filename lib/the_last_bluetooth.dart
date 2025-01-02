// ignore_for_file: constant_identifier_names
import 'dart:async';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:jni/jni.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:the_last_bluetooth/src/android_bluetooth.g.dart' as jni;

import 'src/android_enums.dart' as enums;
import 'src/bluetooth_device.dart';
import 'src/ctrl_bluetooth_device.dart';
import 'src/utils.dart';

export 'src/bluetooth_device.dart';

class TheLastBluetooth {
  static final TheLastBluetooth _instance = TheLastBluetooth._();

  static TheLastBluetooth get instance => _instance;

  late jni.BluetoothManager _manager;
  late jni.BluetoothAdapter _adapter;

  // Our streams for user:
  final _isEnabledCtrl = BehaviorSubject<bool>();
  final _pairedDevicesCtrl = BehaviorSubject<Set<CtrlBluetoothDevice>>();

  TheLastBluetooth._();

  void init() {
    // TODO: maybe don't require permission to init plugin but gradually, huh??
    // TODO: DEVICES OFTEN "BLINK" ABOUT THEIR CONNECTION

    // this is some init stuff - maybe move this to manual init() dispose() ?
    final ctx = jni.Context.fromReference(Jni.getCachedApplicationContext());

    _manager = ctx
        .getSystemService(jni.Context.BLUETOOTH_SERVICE)!
        .as(jni.BluetoothManager.type);
    _adapter = _manager.getAdapter()!;

    // emit devices when enabled, clear when disabled
    _isEnabledCtrl.listen((event) {
      if (event) {
        _pairedDevicesCtrl.add(
          _adapter
              .getBondedDevices()!
              .map(
                (dev) => CtrlBluetoothDevice.fromAndroidBluetoothDevice(dev!),
              )
              .toSet(),
        );
      } else {
        _pairedDevicesCtrl.valueOrNull?.forEach((dev) => dev.close());
        _pairedDevicesCtrl.add(<CtrlBluetoothDevice>{});
      }
    });
    // this will also nicely trigger listener above :)
    _isEnabledCtrl.add(_adapter.isEnabled());

    // Register receiver:
    final tlr = jni.TheLastBroadcastReceiver(
      jni.BroadcastReceiverInterface.implement(
        jni.$BroadcastReceiverInterface(onReceive: onReceive),
      ),
    );
    final filter = jni.IntentFilter();
    for (final action in [
      jni.BluetoothAdapter.ACTION_STATE_CHANGED,
      jni.BluetoothDevice.ACTION_BOND_STATE_CHANGED,
      jni.BluetoothDevice.ACTION_ACL_CONNECTED,
      jni.BluetoothDevice.ACTION_ACL_DISCONNECTED,
      jni.BluetoothDevice.ACTION_NAME_CHANGED,
      jni.BluetoothDevice.ACTION_ALIAS_CHANGED,
      enums.BluetoothDevice.ACTION_BATTERY_LEVEL_CHANGED.toJString(),
    ]) {
      filter.addAction(action);
    }
    ctx.registerReceiver(tlr, filter);
  }

  void onReceive(jni.Context? context, jni.Intent? intent) {
    (context, intent) = (context!, intent!);

    /// Shitty helper function for less writing
    CtrlBluetoothDevice? getPairedDevice(String mac) =>
        _pairedDevicesCtrl.value.firstWhereOrNull((dev) => dev.mac == mac);

    final action = intent.getAction()!.toDString();
    switch (action) {
      case enums.BluetoothAdapter.ACTION_STATE_CHANGED:
        _isEnabledCtrl.addDistinct(
          intent.getIntExtra(jni.BluetoothAdapter.EXTRA_STATE, -1) ==
              jni.BluetoothAdapter.STATE_ON,
        );
        break;
      case enums.BluetoothDevice.ACTION_BOND_STATE_CHANGED:
        final extraDev = getDeviceExtra(intent);
        final bondState =
            intent.getIntExtra(jni.BluetoothDevice.EXTRA_BOND_STATE, -1);
        switch (bondState) {
          case jni.BluetoothDevice.BOND_BONDED:
            _pairedDevicesCtrl.add(
              _pairedDevicesCtrl.value
                ..add(
                  CtrlBluetoothDevice.fromAndroidBluetoothDevice(extraDev.dev),
                ),
            );
            break;
          case jni.BluetoothDevice.BOND_NONE:
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
      case enums.BluetoothDevice.ACTION_ACL_CONNECTED:
        getPairedDevice(getDeviceExtra(intent).mac)?.isConnectedCtrl.add(true);
        break;
      case enums.BluetoothDevice.ACTION_ACL_DISCONNECTED:
        getPairedDevice(getDeviceExtra(intent).mac)?.isConnectedCtrl.add(false);
        break;
      case enums.BluetoothDevice.ACTION_NAME_CHANGED:
        final dev = getDeviceExtra(intent);
        getPairedDevice(dev.mac)?.nameCtrl.add(dev.dev.getName()!.toDString());
        break;
      case enums.BluetoothDevice.ACTION_ALIAS_CHANGED:
        final dev = getDeviceExtra(intent);
        getPairedDevice(dev.mac)
            ?.aliasCtrl
            .add(dev.dev.getAlias()!.toDString());
        break;
      case enums.BluetoothDevice.ACTION_BATTERY_LEVEL_CHANGED:
        final dev = getDeviceExtra(intent);
        var battery = intent.getIntExtra(
            enums.BluetoothDevice.EXTRA_BATTERY_LEVEL.toJString(), -1);
        if (battery < 0) {
          // fallback, but still can return -1
          battery = jni.TheLastUtils.bluetoothDeviceBatteryLevel(dev.dev);
        }
        if (battery >= 0) {
          getPairedDevice(dev.mac)?.batteryLevelCtrl.addDistinct(battery);
        }
    }
  }

  // ###### IMPORTANT NOTES ######
  // Current stance on detecting closed socket:
  // it seems that android gives me absolutely no way of detecting that, besides
  // actually reading/writing and getting an exception
  // That wouldn't be a problem if i continuously used .read() in while(true)
  // loop, but I don't want yet to port it to separate Isolate (and it doesn't
  // seem to work out-of-the-box). So, right now, you just wait until your first
  // write (after close) to get this lovely surprise!
  /// Returned [StreamChannel] is your go-to place for literally every aspect
  /// of communication with your socket 🎉
  ///
  /// - You want to write? `channel.sink.add(data)`
  /// - Want to read? `channel.stream.listen()`
  /// - Want to close? `channel.sink.close()`.
  /// - Want to know when it's closed? `channel.stream.listen().asFuture()`
  ///
  /// 🥰🥰
  StreamChannel<Uint8List> connectRfcomm(
      BluetoothDevice device, String serviceUuid,
      {bool force = false}) {
    final ourDev =
        _pairedDevicesCtrl.value.firstWhereOrNull((d) => d.mac == device.mac);
    assert(ourDev?.isConnected.valueOrNull ?? false);
    final toDevice = StreamController<Uint8List>();
    final fromDevice = StreamController<Uint8List>.broadcast();
    StreamSubscription? fromDeviceLoopSub;
    final jniDev = _adapter.getRemoteDevice(ourDev!.mac.toJString())!;
    final socket = jniDev.createRfcommSocketToServiceRecord(
      jni.UUID.fromString(serviceUuid.toJString()),
    )!;
    if (socket.isConnected()) {
      if (force) {
        socket.close();
      } else {
        throw "Device is already connected";
      }
    }
    socket.connect();
    final jniToDevice = socket.getOutputStream()!;
    final jniFromDevice = socket.getInputStream()!;

    closeEverything() {
      toDevice.close();
      fromDevice.close();
      fromDeviceLoopSub?.cancel();
      socket.close();
    }

    toDevice.stream.listen((received) {
      final buffer = JByteArray(received.length);
      received.forEachIndexed((i, e) => buffer[i] = e);
      try {
        // maybe: make new isolate for this some day
        jniToDevice.write$1(buffer);
      } catch (_) {
        closeEverything();
      }
    }, onDone: () {
      closeEverything();
    });

    fromDeviceLoopSub = loopStream(() async {
      try {
        // okay, listen, i don't know WHAT THE FUCK is a right method to detect
        // this socket disconnecting. even this, literally spelled out shit
        // "IS_CONNECTED" is always returning true. i will just try-catch
        // everything and pray it works
        if (!socket.isConnected()) return false;
        final available = jniFromDevice.available();
        if (available > 0) {
          final buffer = JByteArray(1024);
          try {
            final read = jniFromDevice.read$1(buffer);
            if (read < 0) return false;
            fromDevice.add(
              Uint8List.fromList(
                List.generate(
                  read,
                  (i) => buffer[i],
                ),
              ),
            );
          } catch (_) {
            return false;
          }
        } else if (available < 0) {
          return false;
        } else {
          // input lag will be *at most* 10ms
          // Apple Vision Pro is 12ms
          // we're good
          await Future.delayed(const Duration(milliseconds: 10));
        }
      } catch (_) {
        return false;
      }
      return true;
    }).listen((_) {}, onDone: () {
      closeEverything();
    });
    return StreamChannel(fromDevice.stream, toDevice.sink);
  }

  // maybetodo: Make this real ??
  ValueStream<bool> get isAvailable => Stream.value(true).shareValue();

  ValueStream<bool> get isEnabled => _isEnabledCtrl.stream;

  ValueStream<Set<BluetoothDevice>> get pairedDevices =>
      _pairedDevicesCtrl.stream;
}
