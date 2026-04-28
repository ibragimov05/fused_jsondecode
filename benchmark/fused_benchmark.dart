import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// Measure the speed of the json decode.
///
/// [N] is the number of iterations.
/// [bytes] is the bytes to decode.
///
/// Returns the speed in nanoseconds per byte.
double measureSpeedString(int N, Uint8List bytes) {
  final sw = Stopwatch()..start();

  try {
    for (var i = 0; i < N; i++) {
      jsonDecode(utf8.decode(bytes));
    }
  } finally {
    sw.stop();
  }

  final usPerIteration = sw.elapsedMicroseconds / N;
  final nsPerByte = (usPerIteration * 1000) / bytes.length;

  return nsPerByte;
}

/// Measure the speed of the fused json decode.
///
/// [N] is the number of iterations.
/// [bytes] is the bytes to decode.
///
/// Returns the speed in nanoseconds per byte.
double measureSpeedUint8List(int N, Uint8List bytes) {
  final decoder = const Utf8Decoder().fuse(const JsonDecoder());

  final sw = Stopwatch()..start();

  try {
    for (var i = 0; i < N; i++) {
      decoder.convert(bytes);
    }
  } finally {
    sw.stop();
  }

  final usPerIteration = sw.elapsedMicroseconds / N;
  final nsPerByte = (usPerIteration * 1000) / bytes.length;

  return nsPerByte;
}

void main(List<String> args) => runZonedGuarded<void>(
  () {
    final bytes = File('large.json').readAsBytesSync();
    const N = 100; // More iterations = more stable measurement.

    final slow = measureSpeedString(N, bytes);
    final fast = measureSpeedUint8List(N, bytes);

    print('utf8.decode + jsonDecode:   ${slow.toStringAsFixed(2)} ns/byte');
    print('Utf8Decoder.fuse(Decoder):  ${fast.toStringAsFixed(2)} ns/byte');
    print(
      'Speedup: ${(slow / fast).toStringAsFixed(2)}x '
      '(${((1 - fast / slow) * 100).toStringAsFixed(1)}% faster)',
    );
  },
  (error, stack) {
    print("Error: ${error.toString()}\nStack: ${stack.toString()}");
  },
);
