import 'dart:async';

import 'package:fused_jsondecode/fused_jsondecode.dart';
import 'package:http/http.dart' as http;

Future<Map<String, Object?>> fetchData(Uri url) async {
  final response = await http.get(url);
  final decoded = jsonDecode$Fused(response.bodyBytes);

  if (decoded case final Map<String, Object?> data) {
    return data;
  }

  throw FormatException('Invalid JSON format: ${decoded.runtimeType}');
}

@pragma('vm:entry-point')
void main(List<String> args) => runZonedGuarded<void>(
  () async {
    final data = await fetchData(
      Uri.parse('https://raw.githubusercontent.com/ibragimov05/fused_jsondecode/main/large.json'),
    );

    print(data.keys);
  },
  (error, stack) {
    print("Error: ${error.toString()}\nStack: ${stack.toString()}");
  },
);
