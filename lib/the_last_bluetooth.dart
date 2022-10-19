
import 'the_last_bluetooth_platform_interface.dart';

class TheLastBluetooth {
  Future<String?> getPlatformVersion() {
    return TheLastBluetoothPlatform.instance.getPlatformVersion();
  }

  Future<bool?> isAvailable() {
    return TheLastBluetoothPlatform.instance.isAvailable();
  }
}
