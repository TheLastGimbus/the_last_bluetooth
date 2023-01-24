import 'dart:typed_data';

import 'package:stream_channel/stream_channel.dart';

/// Object representing a rfcomm connection to a [BluetoothDevice]
/// You're an adult, you are supposed to manage which device is it
///
/// [io] is a [StreamChannel] holding a socket communication.
///
/// Note that [io.stream] is a broadcast, so you can listen how many times
/// you want
///
/// If you want to close the connection, close the [io.sink].
/// If you want to listen for closing (for example when device disconnects),
/// listen when [io.stream] closes 👍
///
/// It's as simple as that
class BluetoothConnection {
  final StreamChannel<Uint8List> io;

  const BluetoothConnection(
    this.io,
  );
}
