import 'package:education_app/features/guided/lesson_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Smoke-Tests für die geteilten Lektions-Bausteine, auf denen sowohl die
/// Lese- als auch die Zahlen-Lektion aufbauen. Sie sichern den gemeinsamen
/// Rahmen ab, den beide Lektionen benutzen (Dedup-Punkt aus dem Review).
void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('StepScaffold', () {
    testWidgets('zeigt hero, body und die Aktions-Knöpfe', (tester) async {
      var primaryTapped = false;
      var backTapped = false;

      await tester.pumpWidget(wrap(StepScaffold(
        hero: const Text('HERO'),
        body: const Text('BODY'),
        primaryLabel: 'Weiter',
        onPrimary: () => primaryTapped = true,
        onBack: () => backTapped = true,
      )));

      expect(find.text('HERO'), findsOneWidget);
      expect(find.text('BODY'), findsOneWidget);
      expect(find.text('Weiter'), findsOneWidget);
      expect(find.text('Zurück'), findsOneWidget);

      await tester.tap(find.text('Weiter'));
      await tester.tap(find.text('Zurück'));
      expect(primaryTapped, isTrue);
      expect(backTapped, isTrue);
    });

    testWidgets('ohne onBack erscheint kein Zurück-Knopf', (tester) async {
      await tester.pumpWidget(wrap(const StepScaffold(
        content: Text('NUR-INHALT'),
        primaryLabel: 'Los',
      )));

      expect(find.text('NUR-INHALT'), findsOneWidget);
      expect(find.text('Zurück'), findsNothing);
      expect(find.text('Los'), findsOneWidget);
    });
  });

  group('LessonStepView', () {
    testWidgets('titelt mit der aktuellen Periode und zeigt den Schritt',
        (tester) async {
      final controller = StepController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(MaterialApp(
        home: LessonStepView(
          title: 'Lektion',
          periods: const ['Vorbereitung', 'Benennen', 'Geschafft'],
          controller: controller,
          step: 0,
          onStepChanged: (_) {},
          pages: const [Text('SEITE-0'), Text('SEITE-1'), Text('SEITE-2')],
        ),
      ));
      await tester.pumpAndSettle();

      // AppBar-Titel = "$title · <Periode des aktuellen Schritts>".
      expect(find.text('Lektion · Vorbereitung'), findsOneWidget);
      // Die erste Seite ist sichtbar.
      expect(find.text('SEITE-0'), findsOneWidget);
    });
  });
}
