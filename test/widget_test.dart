import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

import 'package:gonow/main.dart';

void main() {
  testWidgets('App launches into splash then onboarding', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GoNowApp());
    await tester.pump();

    expect(find.byType(LottieBuilder), findsOneWidget);

    await tester.pumpAndSettle(const Duration(milliseconds: 1700));

    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Get Started'), findsNothing);
  });
}
