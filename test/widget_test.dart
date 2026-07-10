import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memory_cards/main.dart';

void main() {
  testWidgets('App boots and shows splash then home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MemoryCardsApp()));

    // Splash screen shows first.
    expect(find.text('Memory Cards'), findsOneWidget);

    // Let the splash's Future.delayed(1800ms) fire and settle animations.
    await tester.pump(const Duration(milliseconds: 1900));
    await tester.pumpAndSettle();

    // Home screen action is now visible.
    expect(find.text('Jugar por niveles'), findsOneWidget);
  });
}
