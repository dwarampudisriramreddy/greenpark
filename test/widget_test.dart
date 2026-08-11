import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:greenpark/core/theme/app_theme.dart';

void main() {
  testWidgets('App theme provides both light and dark themes',
      (WidgetTester tester) async {
    final light = AppTheme.light;
    expect(light.colorScheme, isNotNull);
    expect(light.brightness, Brightness.light);

    final dark = AppTheme.dark;
    expect(dark.colorScheme, isNotNull);
    expect(dark.brightness, Brightness.dark);
  });
}
