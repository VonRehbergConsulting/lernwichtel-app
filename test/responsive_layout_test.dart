import 'package:education_app/core/responsive.dart';
import 'package:education_app/core/widgets/adaptive_home_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sichert die geräteklassen-abhängige Ausrichtung/Layout-Logik ab, nachdem die
/// App Hochformat auf Handys erlaubt (Breakpoint wanderte von Höhe → Breite).
void main() {
  /// Rendert [child] bei fester logischer Bildschirmgröße.
  Future<void> pumpAt(
    WidgetTester tester,
    Size size,
    Widget child,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
  }

  testWidgets('Handy im Hochformat gilt als kompakt, nicht als Tablet',
      (tester) async {
    late bool compact;
    late bool tablet;
    await pumpAt(tester, const Size(390, 844), Builder(builder: (context) {
      compact = context.isCompact;
      tablet = context.isTablet;
      return const SizedBox();
    }));
    expect(compact, isTrue);
    expect(tablet, isFalse);
  });

  testWidgets('Tablet im Querformat ist nicht kompakt, sondern Tablet',
      (tester) async {
    late bool compact;
    late bool tablet;
    await pumpAt(tester, const Size(1194, 834), Builder(builder: (context) {
      compact = context.isCompact;
      tablet = context.isTablet;
      return const SizedBox();
    }));
    expect(compact, isFalse);
    expect(tablet, isTrue);
  });

  testWidgets('AdaptiveHomeLayout stapelt auf schmalem Handy ohne Overflow',
      (tester) async {
    await pumpAt(
      tester,
      const Size(390, 844),
      AdaptiveHomeLayout(
        sidebar: const [Text('Lektion'), SizedBox(height: 10), Text('Banner')],
        grid: GridView.count(
          crossAxisCount: 2,
          children: const [
            Card(child: Center(child: Text('A'))),
            Card(child: Center(child: Text('B'))),
            Card(child: Center(child: Text('C'))),
            Card(child: Center(child: Text('D'))),
          ],
        ),
      ),
    );
    // Kein RenderFlex-Overflow (würde den Test als Fehler markieren) und die
    // Kopfzeile plus Grid sind sichtbar.
    expect(tester.takeException(), isNull);
    expect(find.text('Lektion'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
  });
}
