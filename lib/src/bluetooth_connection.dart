import 'dart:async';
import 'dart:typed_data';

// NOTE: No idea how to implement stuff here - closing etc
class BluetoothConnection {
  final Stream<Uint8List> input;
  final StreamSink<Uint8List> output;

  const BluetoothConnection(
    this.input,
    this.output,
  );
}
