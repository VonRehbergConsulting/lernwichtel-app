import 'package:education_app/core/widgets/menu_tile.dart';
import 'package:education_app/core/widgets/tile_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Deckt die geräteabhängige Anordnung der Auswahl-Menüs ab: Zeilen (Liste) auf
/// dem Handy, Raster auf dem Tablet.
void main() {
  Future<void> pumpAt(WidgetTester tester, Size size, Widget child) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
  }

  final items = [
    const MenuTile(
      iconId: 'x',
      emoji: '👪',
      label: 'Kinder',
      color: Color(0xFF90CAF9),
      onTap: _noop,
    ),
    const MenuTile(
      iconId: 'y',
      emoji: '🖼️',
      label: 'Bilder',
      color: Color(0xFFA5D6A7),
      onTap: _noop,
    ),
  ];

  testWidgets('Handy: Menü als Liste (Zeilen), beide Einträge sichtbar',
      (tester) async {
    await pumpAt(tester, const Size(390, 844), TileMenu(children: items));
    tester.takeException(); // evtl. fehlendes Asset -> Emoji-Fallback, ignorieren
    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(GridView), findsNothing);
    expect(find.text('Kinder'), findsOneWidget);
    expect(find.text('Bilder'), findsOneWidget);
  });

  testWidgets('Tablet: Menü als Raster (GridView)', (tester) async {
    await pumpAt(tester, const Size(1194, 834), TileMenu(children: items));
    tester.takeException();
    expect(find.byType(GridView), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
    expect(find.text('Kinder'), findsOneWidget);
  });
}

void _noop() {}
