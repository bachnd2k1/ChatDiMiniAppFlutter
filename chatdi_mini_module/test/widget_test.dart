import 'package:flutter_test/flutter_test.dart';

import 'package:chatdi_mini_module/main.dart' as app_entry;

void main() {
  test('miniAppMain is defined for iOS host embedding', () {
    expect(app_entry.miniAppMain, isA<Future<void> Function()>());
  });
}
