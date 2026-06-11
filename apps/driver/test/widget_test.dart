import 'package:flutter_test/flutter_test.dart';
import 'package:tardadi_driver/main.dart';

void main() {
  testWidgets('Driver app renders login screen', (tester) async {
    await tester.pumpWidget(const TardadiDriverApp());
    expect(find.text('ترددي'), findsOneWidget);
    expect(find.text('تطبيق السائق'), findsOneWidget);
  });
}
