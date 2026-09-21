import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gonow/models/vehicle_listing.dart';
import 'package:gonow/widgets/vehicle_color_picker.dart';

void main() {
  const colors = vehicleColorOptions;

  Widget wrap(
    VehicleColorOption selected,
    ValueChanged<VehicleColorOption> onSelected,
  ) {
    return MaterialApp(
      home: Scaffold(
        body: VehicleColorPicker(
          colors: colors,
          selected: selected,
          onSelected: onSelected,
        ),
      ),
    );
  }

  testWidgets('shows every color name and swatch', (tester) async {
    await tester.pumpWidget(wrap(colors[0], (_) {}));
    await tester.pumpAndSettle();

    expect(find.text('Silver'), findsOneWidget);
    expect(find.text('Sold out'), findsNothing);
  });

  testWidgets('tapping an available swatch reports it as selected', (
    tester,
  ) async {
    VehicleColorOption? picked;
    await tester.pumpWidget(wrap(colors[0], (c) => picked = c));
    await tester.pumpAndSettle();

    // Black is the second, available swatch.
    final blackSwatch = find.byWidgetPredicate(
      (w) => w is Semantics && w.properties.label == 'Black',
    );
    expect(blackSwatch, findsOneWidget);
    await tester.tap(blackSwatch);
    await tester.pumpAndSettle();

    expect(picked?.name, 'Black');
  });

  testWidgets('an unavailable color cannot be selected and shows Sold out', (
    tester,
  ) async {
    VehicleColorOption? picked;
    final redOption = colors.firstWhere((c) => c.name == 'Red');
    await tester.pumpWidget(wrap(redOption, (c) => picked = c));
    await tester.pumpAndSettle();

    expect(find.text('Sold out'), findsOneWidget);

    final redSwatch = find.byWidgetPredicate(
      (w) => w is Semantics && w.properties.label == 'Red, sold out',
    );
    expect(redSwatch, findsOneWidget);
    await tester.tap(redSwatch, warnIfMissed: false);
    await tester.pumpAndSettle();

    // onSelected must not fire for a disabled swatch.
    expect(picked, isNull);
  });
}
