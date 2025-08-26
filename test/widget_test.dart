import 'package:flutter_test/flutter_test.dart';
import 'package:shiftos/main.dart';

void main() {
  testWidgets('smoke test', (tester) async {
    await tester.pumpWidget(const ShiftOSApp());
  });
}
