import 'dart:typed_data';

import 'package:stream_channel/stream_channel.dart';

// NOTE: No idea how to implement stuff here - closing etc
class BluetoothConnection {
  final StreamChannel<Uint8List> io;

  const BluetoothConnection(
    this.io,
  );
}
