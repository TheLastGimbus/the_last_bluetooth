import 'package:rxdart/rxdart.dart';

class BluetoothDevice {
  const BluetoothDevice(
    this.mac, {
    required BehaviorSubject<String> nameStream,
    required BehaviorSubject<String> aliasStream,
    required BehaviorSubject<bool> isConnectedStream,
    required BehaviorSubject<int> batteryLevelStream,
  })  : _batteryLevelStream = batteryLevelStream,
        _isConnectedStream = isConnectedStream,
        _aliasStream = aliasStream,
        _nameStream = nameStream;

  /// Devices that randomize their MACs are currently out of scope of this
  /// library, and I just know too few about this. This will be a breaking
  /// change if it ever comes up
  final String mac;

  final BehaviorSubject<String> _nameStream;
  final BehaviorSubject<String> _aliasStream;
  final BehaviorSubject<bool> _isConnectedStream;
  final BehaviorSubject<int> _batteryLevelStream;

  ValueStream<String> get name => _nameStream.stream;

  ValueStream<String> get alias => _aliasStream.stream;

  // I have a problem with this
  // I'm not sure if I should abstract "stuff that doesn't work when not
  // connected" away to some sub-class, or leave it just not emitting/responding
  ValueStream<bool> get isConnected => _isConnectedStream.stream;

  ValueStream<int> get batteryLevel => _batteryLevelStream.stream;
}
