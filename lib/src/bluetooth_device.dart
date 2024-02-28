import 'package:rxdart/rxdart.dart';

abstract class BluetoothDevice {
  String get mac;

  ValueStream<String> get name;

  ValueStream<String> get alias;

  ValueStream<bool> get isConnected;

  Future<Set<String>> get uuids;

  ValueStream<int> get battery;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BluetoothDevice &&
          runtimeType == other.runtimeType &&
          mac == other.mac;

  @override
  int get hashCode => mac.hashCode;
}
