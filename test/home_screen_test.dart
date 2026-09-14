import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:gonow/providers/auth_provider.dart';
import 'package:gonow/screens/home/home_screen.dart';
import 'package:gonow/widgets/app_bottom_nav.dart';

late AuthProvider auth;

Widget _wrap() {
  auth = AuthProvider();
  return ChangeNotifierProvider.value(
    value: auth,
    child: const MaterialApp(home: HomeScreen()),
  );
}

void main() {
  testWidgets('renders every section of the design', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('Standard member'), findsOneWidget);
    expect(find.text('Promotions Today 20%'), findsOneWidget);
    expect(find.text('Book your Scooter now!!'), findsOneWidget);
    for (final chip in ['Nearby', 'Battery 80%+', 'Daily', 'Weekly']) {
      expect(find.text(chip), findsOneWidget, reason: 'missing chip: $chip');
    }
    expect(find.text('e-sctooer'), findsOneWidget);
    expect(find.text('Fortuner GR'), findsOneWidget);
    expect(find.text(r'$ 7.5/day'), findsOneWidget);
    expect(find.byType(AppBottomNav), findsOneWidget);
  });

  testWidgets('falls back to a rider name when signed out', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    // No user on the provider, so the header must not render null or crash.
    expect(find.text('Rider'), findsOneWidget);
    expect(find.text('R'), findsOneWidget, reason: 'avatar initial');
  });

  testWidgets('selecting a filter chip moves the highlight', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    Color chipColor(String label) {
      final container = tester.widget<Container>(
        find
            .ancestor(of: find.text(label), matching: find.byType(Container))
            .first,
      );
      return (container.decoration as BoxDecoration).color!;
    }

    final limeWhenDefault = chipColor('Nearby');

    await tester.tap(find.text('Daily'));
    await tester.pumpAndSettle();

    expect(chipColor('Daily'), limeWhenDefault);
    expect(chipColor('Nearby'), isNot(limeWhenDefault));
  });

  testWidgets('unbuilt nav tabs say so rather than doing nothing', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Rentals'));
    await tester.pump();

    expect(find.textContaining('not built yet'), findsOneWidget);
  });
}
