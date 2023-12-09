import 'dart:async';

import 'package:jni/jni.dart';
import 'package:the_last_bluetooth/src/android_bluetooth.g.dart';

int sum(int a, int b) => a + b;

Future<int> sumAsync(int a, int b) async => a + b;

// can't do!! help dart team :((
class MyBroadcastReceiver extends BroadcastReceiver {
  @override
  void onReceive(Context context, Intent intent) {
    super.onReceive(context, intent);
    print(intent);
  }
}

class TheLastBluetooth {
  TheLastBluetooth() {
    final ctx = Context.fromRef(Jni.getCachedApplicationContext());
    final receiver = MyBroadcastReceiver();
    ctx.registerReceiver(receiver, IntentFilter());
  }
}
