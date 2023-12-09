import 'dart:async';

int sum(int a, int b) => a + b;

Future<int> sumAsync(int a, int b) async {
  return a + b;
}
