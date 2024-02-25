import 'dart:async';

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

  TheLastBluetooth._() {
    // this is some init stuff - maybe move this to manual init() dispose() ?
    final ctx = android.Context.fromRef(Jni.getCachedApplicationContext());
    _manager = android.BluetoothManager.fromRef(
      ctx
          .getSystemService(android.Context.BLUETOOTH_SERVICE.toJString())
          .reference,
    );
    _adapter = _manager.getAdapter();

    _isEnabledCtrl.add(_adapter.isEnabled());

    fb.BroadcastReceiver receiver = fb.BroadcastReceiver(
      names: <String>[android.BluetoothAdapter.ACTION_STATE_CHANGED],
    );
    receiver.messages.listen((event) {
      print(event);
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
            case android.BluetoothAdapter.STATE_OFF:
              _isEnabledCtrl.add(false);
          }
          break;
      }
    });
    receiver.start();
  }

  // TODO: Make this real
  ValueStream<bool> get isAvailable => Stream.value(true).shareValue();

  ValueStream<bool> get isEnabled => _isEnabledCtrl.stream;

  ValueStream<Set<BluetoothDevice>> get pairedDevices =>
      Stream.value(<BluetoothDevice>{}).shareValue();
}
