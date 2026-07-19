import 'dart:math';

/// Die vier Rechen-Bereiche.
enum MathModule { ziffern, zehner, addieren, subtrahieren }

extension MathModuleX on MathModule {
  /// Schluessel fuer DB/Repository (siehe MathSkills.module).
  String get key => switch (this) {
        MathModule.ziffern => 'ziffern',
        MathModule.zehner => 'zehner',
        MathModule.addieren => 'addieren',
        MathModule.subtrahieren => 'subtrahieren',
      };

  String get label => switch (this) {
        MathModule.ziffern => 'Ziffern',
        MathModule.zehner => 'Zahlen bis 100',
        MathModule.addieren => 'Plus',
        MathModule.subtrahieren => 'Minus',
      };

  String get emoji => switch (this) {
        MathModule.ziffern => '🔢',
        MathModule.zehner => '💯',
        MathModule.addieren => '➕',
        MathModule.subtrahieren => '➖',
      };
}

/// Wie die Aufgabe dargestellt wird.
enum MathVisual { objekte, zehnerEiner, gleichung }

/// Ein Zaehl-Objekt: Bild (slug) + deutsche Wortformen fuers Vorlesen.
class MathObject {
  const MathObject(this.slug, this.singular, this.plural, this.artikel);
  final String slug; // Bild: assets/images/standard/<slug>.webp
  final String singular; // "Ball"
  final String plural; // "Bälle"
  final String artikel; // "ein" oder "eine" (fuer die Eins)
}

/// Zaehl-Objekte = unsere generierten Wortbilder (Wiedererkennung zum
/// Lesen-Modul). Alternieren je Aufgabe.
const mathObjects = <MathObject>[
  MathObject('apfel', 'Apfel', 'Äpfel', 'ein'),
  MathObject('ball', 'Ball', 'Bälle', 'ein'),
  MathObject('fisch', 'Fisch', 'Fische', 'ein'),
  MathObject('banane', 'Banane', 'Bananen', 'eine'),
  MathObject('auto', 'Auto', 'Autos', 'ein'),
  MathObject('biene', 'Biene', 'Bienen', 'eine'),
  MathObject('ente', 'Ente', 'Enten', 'eine'),
  MathObject('stern', 'Stern', 'Sterne', 'ein'),
  MathObject('zitrone', 'Zitrone', 'Zitronen', 'eine'),
  MathObject('katze', 'Katze', 'Katzen', 'eine'),
];

/// Eine konkrete Rechenaufgabe.
class MathProblem {
  const MathProblem({
    required this.module,
    required this.answer,
    required this.visual,
    this.a,
    this.b,
    this.op,
    this.object = 'apfel',
  });

  final MathModule module;
  final int answer;
  final MathVisual visual;

  /// Operanden (Bedeutung je Modul): Ziffern/Zehner -> a = Zahl;
  /// Plus/Minus -> a, b, op.
  final int? a;
  final int? b;
  final String? op; // '+' oder '−'

  /// Slug des Zaehl-Objekts (bei Objekt-Darstellung).
  final String object;

  /// Kurzer Text fuers Protokoll (MathAttempts.problem).
  String get promptText => switch (visual) {
        MathVisual.gleichung => '$a $op $b',
        _ => '$a',
      };
}

/// Erzeugt eine Aufgabe passend zum Modul und Schwierigkeitsgrad (Level ab 1).
/// Erzeugt eine Aufgabe. [maxNumber] begrenzt bei den Ziffern den Zahlenraum
/// auf die bereits eingeführten Zahlen (selbstständiges Üben läuft dem
/// Lektions-Fortschritt so nicht voraus).
MathProblem generateProblem(
  MathModule module,
  int level,
  Random rnd, {
  int? maxNumber,
}) {
  final l = level.clamp(1, 6);
  final object = mathObjects[rnd.nextInt(mathObjects.length)];
  switch (module) {
    case MathModule.ziffern:
      // Zahlenraum waechst mit dem Level; die 0 erst ab Level 4.
      const maxByLevel = [3, 5, 9, 9, 9, 9];
      final byLevel = maxByLevel[l - 1];
      final max = maxNumber == null || maxNumber >= byLevel ? byLevel : maxNumber;
      final min = (l >= 4 && maxNumber == null) ? 0 : 1;
      final n = min + rnd.nextInt(max - min + 1);
      return MathProblem(
          module: module,
          answer: n,
          visual: MathVisual.objekte,
          a: n,
          object: object.slug);

    case MathModule.zehner:
      const ranges = [
        [10, 20],
        [10, 50],
        [20, 100],
        [0, 100],
        [0, 100],
        [0, 100],
      ];
      final r = ranges[l - 1];
      final n = r[0] + rnd.nextInt(r[1] - r[0] + 1);
      return MathProblem(
          module: module, answer: n, visual: MathVisual.zehnerEiner, a: n);

    case MathModule.addieren:
      const maxSum = [5, 10, 20, 20, 50, 100];
      final m = maxSum[l - 1];
      final lo = l >= 4 ? 0 : 1; // 0 erst spaeter
      final a = lo + rnd.nextInt((m - lo) - lo + 1);
      final b = lo + rnd.nextInt((m - a) - lo + 1);
      return MathProblem(
        module: module,
        answer: a + b,
        visual: MathVisual.gleichung,
        a: a,
        b: b,
        op: '+',
        object: object.slug,
      );

    case MathModule.subtrahieren:
      const maxN = [5, 10, 20, 20, 50, 100];
      final m = maxN[l - 1];
      final lo = l >= 4 ? 0 : 1;
      final a = lo + rnd.nextInt((m - lo) + 1);
      final b = lo + rnd.nextInt((a - lo) + 1); // b <= a -> kein negatives Ergebnis
      return MathProblem(
        module: module,
        answer: a - b,
        visual: MathVisual.gleichung,
        a: a,
        b: b,
        op: '−',
        object: object.slug,
      );
  }
}
