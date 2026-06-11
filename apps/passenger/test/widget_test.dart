import 'package:flutter_test/flutter_test.dart';
import 'package:tardadi_passenger/main.dart';

void main() {
  testWidgets('Passenger app renders map screen', (tester) async {
    await tester.pumpWidget(const TardadiPassengerApp());
    expect(find.text('خريطة الباصات'), findsOneWidget);
  });
}
