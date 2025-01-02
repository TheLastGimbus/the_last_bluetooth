
import 'dart:async';

import 'package:jni/jni.dart';
import 'package:rxdart/rxdart.dart';

extension TheLastJString on JString {
  /// just with [releaseOriginal] true by default
  String toDString({bool releaseOriginal = true}) =>
      toDartString(releaseOriginal: releaseOriginal);
}

extension TheLastSubject<T> on BehaviorSubject<T> {
  void addDistinct(T value) {
    if (valueOrNull != value) {
      add(value);
    }
  }
}

/// stream that does computation() as long as it's listened and computation()
/// returns true
/// when it's .close()d, or returns false, it stops
Stream<bool> loopStream(FutureOr<bool> Function() computation) async* {
  while (true) {
    final status = await computation();
    yield status;
    if (!status) break;
  }
}
