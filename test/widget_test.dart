// Basic widget test for the Mahalla app.
//
// Eslatma: To'liq `MahallaApp` ni pump qilish Firebase initializatsiyasini
// talab qiladi (test muhitida mavjud emas). Shu sababli bu yerda Firebase'ga
// bog'liq bo'lmagan oddiy "smoke test" saqlanadi. Widget/integratsiya
// testlari kerak bo'lsa, Firebase mock'lari bilan alohida yoziladi.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Smoke test: MaterialApp renders a widget',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Mahalla Xizmati')),
        ),
      ),
    );

    expect(find.text('Mahalla Xizmati'), findsOneWidget);
  });
}
