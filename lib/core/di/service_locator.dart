import 'package:get_it/get_it.dart';

import '../../data/db/database.dart';
import '../../data/repositories/child_repository.dart';
import '../../data/repositories/content_repository.dart';
import '../../data/repositories/fund_repository.dart';
import '../../data/repositories/gate_repository.dart';
import '../../data/repositories/math_repository.dart';
import '../../data/repositories/number_repository.dart';
import '../../data/repositories/progression_repository.dart';
import '../../data/repositories/reading_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../features/reading/phonics_player.dart';
import '../audio/audio_service.dart';

final getIt = GetIt.instance;

/// Registriert Datenbank, Services und Repositories. Einmal beim App-Start.
Future<void> setupServiceLocator() async {
  final db = AppDatabase();
  getIt
    ..registerSingleton<AppDatabase>(db)
    ..registerLazySingleton<AudioService>(AudioService.new)
    ..registerLazySingleton<FundRepository>(() => FundRepository(db))
    ..registerLazySingleton<ChildRepository>(
        () => ChildRepository(db, getIt<FundRepository>()))
    ..registerLazySingleton<ContentRepository>(() => ContentRepository(db))
    ..registerLazySingleton<ReadingRepository>(() => ReadingRepository(db))
    ..registerLazySingleton<ProgressionRepository>(
        () => ProgressionRepository(db))
    ..registerLazySingleton<MathRepository>(() => MathRepository(db))
    ..registerLazySingleton<NumberRepository>(() => NumberRepository(db))
    ..registerLazySingleton<SettingsRepository>(() => SettingsRepository(db))
    ..registerLazySingleton<GateRepository>(() => GateRepository(db))
    ..registerLazySingleton<PhonicsPlayer>(
        () => PhonicsPlayer(getIt<ContentRepository>(), getIt<AudioService>()));

  // Seed-Inhalte laden/aktualisieren (versioniert, ohne Fortschrittsverlust).
  await getIt<ContentRepository>().ensureSeeded();
}
