import 'package:rxdart/rxdart.dart';

abstract class BluetoothDevice {
  String get mac;

  ValueStream<String> get name;

  ValueStream<String> get alias;

  ValueStream<bool> get isConnected;

  Future<Set<String>> get uuids;

  ValueStream<int> get battery;
}
