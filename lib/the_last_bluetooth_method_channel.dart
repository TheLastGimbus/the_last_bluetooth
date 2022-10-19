import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'the_last_bluetooth_platform_interface.dart';

/// An implementation of [TheLastBluetoothPlatform] that uses method channels.
class MethodChannelTheLastBluetooth extends TheLastBluetoothPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('the_last_bluetooth');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<bool?> isAvailable() async {
    final isAvailable = await methodChannel.invokeMethod<bool>('isAvailable');
    return isAvailable;
  }
}
