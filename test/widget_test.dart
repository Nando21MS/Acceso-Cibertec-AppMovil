import 'package:flutter_test/flutter_test.dart';

import 'package:accessqr/main.dart';

void main() {
  testWidgets('Verifica que se muestre "hello World"',
      (WidgetTester tester) async {
    // Construye la aplicación y dispara un frame.
    await tester.pumpWidget(MyApp());

    // Verifica que el texto "hello World" aparece una vez.
    expect(find.text('hello World'), findsOneWidget);

    // Verifica que el texto "Material App Bar" aparece en el AppBar.
    expect(find.text('Material App Bar'), findsOneWidget);
  });
}
