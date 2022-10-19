import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'the_last_bluetooth_method_channel.dart';

abstract class TheLastBluetoothPlatform extends PlatformInterface {
  /// Constructs a TheLastBluetoothPlatform.
  TheLastBluetoothPlatform() : super(token: _token);

  static final Object _token = Object();

  static TheLastBluetoothPlatform _instance = MethodChannelTheLastBluetooth();

  /// The default instance of [TheLastBluetoothPlatform] to use.
  ///
  /// Defaults to [MethodChannelTheLastBluetooth].
  static TheLastBluetoothPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [TheLastBluetoothPlatform] when
  /// they register themselves.
  static set instance(TheLastBluetoothPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool?> isAvailable() {
    throw UnimplementedError('isAvailable() has not been implemented.');
  }
}
