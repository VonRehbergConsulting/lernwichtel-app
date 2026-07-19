import 'package:bloc_test/bloc_test.dart';
import 'package:drift/native.dart';
import 'package:education_app/data/db/database.dart';
import 'package:education_app/data/repositories/math_repository.dart';
import 'package:education_app/features/math/bloc/math_bloc.dart';
import 'package:education_app/features/math/model/math_problem.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late MathRepository repo;
  late int childId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = MathRepository(db);
    final child = await db
        .into(db.children)
        .insertReturning(ChildrenCompanion.insert(name: 'T'));
    childId = child.id;
  });

  tearDown(() => db.close());

  blocTest<MathBloc, MathState>(
    'MathStarted liefert eine Aufgabe (ready)',
    build: () => MathBloc(repo: repo),
    act: (bloc) => bloc.add(MathStarted(childId, MathModule.ziffern)),
    expect: () => [
      isA<MathState>()
          .having((s) => s.status, 'status', MathStatus.ready)
          .having((s) => s.problem, 'problem', isNotNull),
    ],
  );

  blocTest<MathBloc, MathState>(
    'DigitTyped fuellt die Eingabe',
    build: () => MathBloc(repo: repo),
    act: (bloc) async {
      bloc.add(MathStarted(childId, MathModule.ziffern));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc
        ..add(const DigitTyped(4))
        ..add(const DigitTyped(2));
    },
    skip: 2, // Start-Ready + erste Ziffer
    expect: () => [
      isA<MathState>().having((s) => s.entered, 'entered', '42'),
    ],
  );
}
