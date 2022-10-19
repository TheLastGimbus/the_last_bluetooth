import 'package:flutter_test/flutter_test.dart';
import 'package:the_last_bluetooth/the_last_bluetooth.dart';
import 'package:the_last_bluetooth/the_last_bluetooth_platform_interface.dart';
import 'package:the_last_bluetooth/the_last_bluetooth_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockTheLastBluetoothPlatform
    with MockPlatformInterfaceMixin
    implements TheLastBluetoothPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final TheLastBluetoothPlatform initialPlatform = TheLastBluetoothPlatform.instance;

  test('$MethodChannelTheLastBluetooth is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTheLastBluetooth>());
  });

  test('getPlatformVersion', () async {
    TheLastBluetooth theLastBluetoothPlugin = TheLastBluetooth();
    MockTheLastBluetoothPlatform fakePlatform = MockTheLastBluetoothPlatform();
    TheLastBluetoothPlatform.instance = fakePlatform;

    expect(await theLastBluetoothPlugin.getPlatformVersion(), '42');
  });
}
