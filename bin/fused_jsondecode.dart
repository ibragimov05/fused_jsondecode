import 'dart:async';
import 'dart:io';

import 'package:fused_jsondecode/fused_jsondecode.dart';
import 'package:http/http.dart' as http;

Future<Map<String, Object?>> fetchData(Uri url) async {
  final response = await http.get(url);

  if (response.statusCode != 200) {
    throw HttpException('GET $url failed: ${response.statusCode}');
  }

  if (jsonDecode$Fused(response.bodyBytes) case final Map<String, Object?> data) {
    return data;
  }

  throw FormatException('Invalid JSON format: ${jsonDecode$Fused(response.bodyBytes).runtimeType}');
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
