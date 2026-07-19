import 'package:education_app/features/reading/ui/word_building_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('baubare Wörter: nur Buchstaben, 3..6 Zeichen', () {
    expect(isBuildableWord('Mama'), isTrue);
    expect(isBuildableWord('Öl'), isFalse); // zu kurz
    expect(isBuildableWord('Elefant'), isFalse); // zu lang
    expect(isBuildableWord('Fußball'), isFalse); // 7 Zeichen
    expect(isBuildableWord('Fuß'), isTrue);
    expect(isBuildableWord('a b'), isFalse); // Leerzeichen
    expect(isBuildableWord('Ast'), isTrue);
  });
}
