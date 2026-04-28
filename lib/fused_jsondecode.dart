import 'dart:convert';
import 'dart:typed_data';

/// Suggested usage in production code:
Object? jsonDecode$Fused(Uint8List bytes) {
  final decoder = const Utf8Decoder().fuse(const JsonDecoder());

  return decoder.convert(bytes);
}
