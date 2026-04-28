import 'dart:async';

@pragma('vm:entry-point')
void main(List<String> args) => runZonedGuarded<void>(() {}, (error, stack) {
  print("Error: ${error.toString()}\nStack: ${stack.toString()}");
});
